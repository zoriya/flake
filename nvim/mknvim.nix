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

  initLua =
    # lua
    ''
      vim.opt.rtp:remove(vim.fn.stdpath('config'))              -- ~/.config/nvim
      vim.opt.rtp:remove(vim.fn.stdpath('config') .. "/after")  -- ~/.config/nvim/after
      vim.opt.rtp:prepend('${config}')
      vim.opt.rtp:append('${config}/after')

      ${builtins.readFile (config + "/init.lua")}
    '';

  builder = (import ./bytecompile.nix) {inherit pkgs lib;};
  pack = (import ./pack.nix) {inherit pkgs lib;};

  nvim = builder.byteCompileVim package;

  start = map (p: lib.pipe p [(normalize false) builder.byteCompile]) plugins.start;
  opts = map (p: lib.pipe p [(normalize true) builder.byteCompile]) plugins.opts;
  startPacked = pack.packPlugins start;
in
  pkgs.wrapNeovimUnstable nvim {
    plugins = [startPacked] ++ opts;

    wrapRc = false;
    wrapperArgs = builtins.concatStringsSep " " [
      (lib.optionals (extraPackages != []) ''--prefix PATH : "${lib.makeBinPath extraPackages}"'')
      ''--add-flags "-u ${builder.writeByteCompiledLua "init.lua" initLua}"''
    ];

    inherit withPython3 withNodeJs withPerl withRuby extraPython3Packages extraLuaPackages;
  }
