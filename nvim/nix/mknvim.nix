{
  pkgs,
  lib,
  ...
}: {
  package ? pkgs.neovim,
  config,
  plugins ? {
    start = [];
    opt = [];
  },
  extraPackages ? [],
  extraLuaPackages ? p: [],
  extraPython3Packages ? p: [],
  withPython3 ? false,
  withPerl ? false,
  withRuby ? false,
  withNodeJs ? false,
}: let
  builder = (import ./bytecompile.nix) {inherit pkgs lib;};
  pack = (import ./pack.nix) {inherit pkgs lib;};
  mkLuarc = (import ./luarc.nix) {inherit pkgs lib;};

  nvim = builder.byteCompileVim package;

  conf = builder.byteCompileLuaDrv (pkgs.runCommandLocal "nvim-config" {} ''
    mkdir $out
    cp -r ${config}/* $out
  '');

  pluginPack = let
    normalize = optional: p: let
      defaultPlugin = {
        plugin = null;
        config = null;
        inherit optional;
      };
    in
      defaultPlugin
      // (
        if (p ? plugin)
        then p
        else {plugin = p;}
      );

    removeDependencies = p: p // {plugin = removeAttrs p.plugin ["dependencies"];};

    preparePlugins = ps:
      map (p:
        lib.pipe p [
          builder.byteCompile
          # we removeDependencies after byteCompiling because byteCompile resets the derivation to it's inital state
          # (with dependencies and idk why)
          removeDependencies
        ])
      ps;

    withDeps = p: [p] ++ builtins.concatMap withDeps (map (normalize false) (p.plugin.dependencies or []));

    plugs = (map (normalize false) plugins.start) ++ (map (normalize true) plugins.opt);
    allPlugs = lib.unique (builtins.concatMap withDeps plugs);
    partitioned = builtins.partition (p: p.optional) (preparePlugins allPlugs);
    opt = map (p: p.plugin) partitioned.right;
    start = let
      # remove plugins marked as "optional" from the start pack
      startPlugs = builtins.filter (p: !(builtins.elem p.plugin opt)) partitioned.wrong;
    in [(pack.packPlugins startPlugs).plugin];
  in
    pkgs.neovimUtils.packDir {packages = {inherit start opt;};};

  initLua =
    # lua
    ''
      vim.opt.rtp = {
        "${conf}",
        "${pluginPack}/pack/packages/start/vimplugin-plugin-pack",
        vim.env.VIMRUNTIME,
        "${conf}/after",
      }
      vim.opt.packpath = {
        "${pluginPack}",
        vim.env.VIMRUNTIME,
      }

      ${builtins.readFile (config + "/init.lua")}
    '';
in {
  nvim = pkgs.wrapNeovimUnstable nvim {
    wrapRc = false;
    wrapperArgs = builtins.concatStringsSep " " [
      (lib.optionals (extraPackages != []) ''--prefix PATH : "${lib.makeBinPath extraPackages}"'')
      ''--add-flags "-u ${builder.writeByteCompiledLua "init.lua" initLua}"''
    ];

    inherit withPython3 withNodeJs withPerl withRuby extraPython3Packages extraLuaPackages;
  };

  nvim-luarc = mkLuarc { nvim = package; inherit plugins; };
}
