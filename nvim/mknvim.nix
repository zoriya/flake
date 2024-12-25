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

  builder = (import ./bytecompile.nix) {inherit pkgs lib;};
  pack = (import ./pack.nix) {inherit pkgs lib;};

  nvim = builder.byteCompileVim package;

  removeDependencies = p: p // {plugin = p.plugin.overrideAttrs (prev: prev // {dependencies = [];});};

  start = map (p: lib.pipe p [(normalize false) removeDependencies builder.byteCompile]) plugins.start;
  opts = map (p: lib.pipe p [(normalize true) removeDependencies builder.byteCompile]) plugins.opts;
  startPacked = pack.packPlugins start;

  pluginPack = lib.pipe ([startPacked] ++ opts) [
    pkgs.neovimUtils.normalizedPluginsToVimPackage
    (p: {packages = p;})
    pkgs.neovimUtils.packDir
  ];

  initLua =
    # lua
    ''
      vim.opt.rtp = {
        "${config}",
        "${pluginPack}",
        vim.env.VIMRUNTIME,
        "${config}/after",
      }
      vim.opt.packpath = {
        "${pluginPack}",
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
