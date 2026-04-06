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

  byteCompile = p: let
    drv = (byteCompileLuaDrv p.plugin).overrideAttrs (
      prev: lib.optionalAttrs (prev ? dependencies) {dependencies = map byteCompile prev.dependencies;}
    );
  in
    p // {plugin = drv;};

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

          # Ensure .desktop file exists for wrapNeovimUnstable
          # (neovim nightly may not ship one)
          mkdir -p $out/share/applications
          if [ ! -e $out/share/applications/nvim.desktop ]; then
            cat > $out/share/applications/nvim.desktop <<EOF
          [Desktop Entry]
          Name=Neovim
          GenericName=Text Editor
          Comment=Edit text files
          TryExec=nvim
          Exec=nvim %F
          Terminal=true
          Type=Application
          Keywords=Text;editor;
          Icon=nvim
          Categories=Utility;TextEditor;
          StartupNotify=false
          MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
          EOF
          fi

          runHook postFixup
        '';
    };
}
