{
  pkgs,
  lib,
  ...
}: {
  package ? pkgs.neovim,
  config,
  plugins ? [],
  extraPackages ? [],
  extraLuaPackages ? p: [],
  extraPython3Packages ? p: [],
  withPython3 ? false,
  withPerl ? false,
  withRuby ? false,
  withNodeJs ? false,
  withSqlite ? false,
}: let
  # Stolen from pkgs.neovimUtils.normalizePlugins but this changes defaultPlugin.optional to true.
  normalizePlugins = plugins: let
    defaultPlugin = {
      plugin = null;
      config = null;
      optional = true;
    };
  in
    map (x:
      defaultPlugin
      // (
        if (x ? plugin)
        then x
        else {plugin = x;}
      ))
    plugins;

  initLua =
    # lua
    ''
      vim.opt.rtp:remove(vim.fn.stdpath('config'))              -- ~/.config/nvim
      vim.opt.rtp:remove(vim.fn.stdpath('config') .. "/after")  -- ~/.config/nvim/after
      vim.opt.rtp:prepend('${config}')
      vim.opt.rtp:prepend('${config}/after')

      ${builtins.readFile (config + "/init.lua")}
    '';

  builder = (import ./bytecompile.nix) {inherit pkgs lib;};

  nvim = builder.byteCompileVim package;
in
  pkgs.wrapNeovimUnstable nvim {
    plugins = builder.byteCompile (normalizePlugins plugins);

    wrapRc = false;
    wrapperArgs = builtins.concatStringsSep " " [
      (lib.optionals (extraPackages != []) ''--prefix PATH : "${lib.makeBinPath extraPackages}"'')
      ''--add-flags "-u ${builder.writeByteCompiledLua "init.lua" initLua}"''
    ];

    inherit withPython3 withNodeJs withPerl withRuby extraPython3Packages extraLuaPackages;
  }
