{
  pkgs,
  lib,
  stdenv,
  ...
}: {
  package ? pkgs.neovim,
  config,
  plugins ? [],
  extraPackages ? [],
  lsp ? [],
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

  externalPackages = extraPackages ++ lsp;
in
  pkgs.wrapNeovimUnstable package {
    # maybe use true here?
    autoconfigure = false;
    autowrapRuntimeDeps = false;

    plugins = normalizePlugins plugins;

    wrapRc = false;
    wrapperArgs = builtins.concatStringsSep " " [
      (lib.optionals (externalPackages != []) ''--prefix PATH : "${lib.makeBinPath externalPackages}"'')
    ];

    inherit withPython3 withNodeJs withPerl withRuby extraPython3Packages extraLuaPackages;
  }
