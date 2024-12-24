{
  pkgs,
  lib,
  ...
}: rec {
  # Stolen from https://github.com/nix-community/nixvim/pull/1887

  writeByteCompiledLua = name: text:
    pkgs.runCommandLocal name {inherit text;} ''
      echo -n "$text" > "$out"

      ${lib.getExe' pkgs.luajit "luajit"} -bd -- "$out" "$out"
    '';

  byteCompileLuaHook = pkgs.makeSetupHook {name = "byte-compile-lua-hook";} (
    let
      luajit = lib.getExe' pkgs.luajit "luajit";
    in
      pkgs.writeText "byte-compile-lua-hook.sh" # bash
      
      ''
        byteCompileLuaPostFixup() {
            # Target is a single file
            if [[ -f $out ]]; then
                if [[ $out = *.lua ]]; then
                    tmp=$(mktemp)
                    ${luajit} -bd -- "$out" "$tmp"
                    mv "$tmp" "$out"
                fi
                return
            fi
            # Target is a directory
            while IFS= read -r -d "" file; do
                tmp=$(mktemp -u "$file.XXXX")
                # Ignore invalid lua files
                if ${luajit} -bd -- "$file" "$tmp"; then
                    mv "$tmp" "$file"
                else
                    echo "WARNING: Ignoring byte compiling error for '$file' lua file" >&2
                fi
            done < <(find "$out" -type f,l -name "*.lua" -print0)
        }
        postFixupHooks+=(byteCompileLuaPostFixup)
      ''
  );

  byteCompileLuaDrv = drv:
    drv.overrideAttrs (
      prev:
        {
          nativeBuildInputs = prev.nativeBuildInputs or [] ++ [byteCompileLuaHook];
        }
        // lib.optionalAttrs (prev ? buildCommand) {
          buildCommand = ''
            ${prev.buildCommand}
            runHook postFixup
          '';
        }
    );

  byteCompile = plugins: let
    byteCompile = p:
      (byteCompileLuaDrv p).overrideAttrs (
        prev: lib.optionalAttrs (prev ? dependencies) {dependencies = map byteCompile prev.dependencies;}
      );
  in
    map (p: p // {plugin = byteCompile p.plugin;}) plugins;

  byteCompileVim = package:
    pkgs.symlinkJoin {
      name = "neovim-byte-compiled-${lib.getVersion package}";
      paths = [package];
      inherit (package) lua meta;
      nativeBuildInputs = [byteCompileLuaHook];
      postBuild =
        # bash
        ''
          # Replace Nvim's binary symlink with a regular file,
          # or Nvim will use original runtime directory
          rm $out/bin/nvim
          cp ${package}/bin/nvim $out/bin/nvim
          runHook postFixup
        '';
    };
}
