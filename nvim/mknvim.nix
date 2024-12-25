{
  pkgs,
  lib,
  ...
}: {
  package ? pkgs.neovim,
  config,
  plugins ? {
    start = [];
    opts = [];
  },
  extraPackages ? [],
  extraLuaPackages ? p: [],
  extraPython3Packages ? p: [],
  withPython3 ? false,
  withPerl ? false,
  withRuby ? false,
  withNodeJs ? false,
  withSqlite ? false,
}: let
  builder = (import ./bytecompile.nix) {inherit pkgs lib;};
  pack = (import ./pack.nix) {inherit pkgs lib;};

  nvim = builder.byteCompileVim package;

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

    preparePlugin = p:
      lib.pipe p [
        removeDependencies
        builder.byteCompile
      ];

    withDeps = p: [p] ++ builtins.concatMap withDeps (map (normalize false) (p.plugin.dependencies or []));

    preparePlugins = ps: map preparePlugin (lib.unique (builtins.concatMap withDeps ps));

    allPlugs = (map (normalize false) plugins.start) ++ (map (normalize true) plugins.opts);
    partitioned = builtins.partition (p: p.optional) (preparePlugins allPlugs);
    start = [(pack.packPlugins partitioned.wrong)];
    opts = partitioned.right;
  in
    lib.pipe (start ++ opts) [
      pkgs.neovimUtils.normalizedPluginsToVimPackage
      (p: {packages = p;})
      pkgs.neovimUtils.packDir
    ];

  initLua =
    # lua
    ''
      vim.opt.rtp = {
        "${config}",
        "${pluginPack}/pack/packages/start/vimplugin-plugin-pack",
        vim.env.VIMRUNTIME,
        "${config}/after",
      }
      vim.opt.packpath = {
        "${pluginPack}/pack/packages/opts",
        vim.env.VIMRUNTIME,
      }

      ${builtins.readFile (config + "/init.lua")}
    '';
in
  pkgs.wrapNeovimUnstable nvim {
    wrapRc = false;
    wrapperArgs = builtins.concatStringsSep " " [
      (lib.optionals (extraPackages != []) ''--prefix PATH : "${lib.makeBinPath extraPackages}"'')
      ''--add-flags "-u ${builder.writeByteCompiledLua "init.lua" initLua}"''
    ];

    inherit withPython3 withNodeJs withPerl withRuby extraPython3Packages extraLuaPackages;
  }
