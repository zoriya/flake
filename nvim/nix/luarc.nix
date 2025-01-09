{
  pkgs,
  lib,
  ...
}: {
  nvim,
  plugins ? {
    start = [];
    opt = [];
  },
  meta ? {luvit = true;},
  lua-version ? "5.1",
  disabled-diagnostics ? [],
}: let
  # stolen from https://github.com/mrcjkb/nix-gen-luarc-json
  pluginPackages =
    map (
      x:
        if x ? plugin
        then x.plugin
        else x
    )
    (plugins.start ++ plugins.opt);
  partitions = builtins.partition (plugin:
    plugin.vimPlugin
    or false
    || plugin.pname or "" == "nvim-treesitter")
  pluginPackages;
  nvim-plugins = partitions.right;
  rocks = partitions.wrong;
  plugin-luadirs = builtins.map (plugin: "${plugin}/lua") nvim-plugins;
  pkg-libdirs = builtins.map (pkg: "${pkg}/lib/lua/${lua-version}") rocks;
  pkg-sharedirs = builtins.map (pkg: "${pkg}/share/lua/${lua-version}") rocks;

  luarc = {
    "$schema" = "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json";
    runtime = {
      version = "LuaJIT";
    };
    workspace = {
      checkThirdParty = false;
      library =
        [
          "${nvim}/share/nvim/runtime/lua"
          "$VIMRUNTIME/lua"
          "\${3rd}/busted/library"
          "\${3rd}/luassert/library"
        ]
        ++ plugin-luadirs
        ++ pkg-libdirs
        ++ pkg-sharedirs
        ++ (lib.optional (meta.luvit or false) "${pkgs.vimPlugins.luvit-meta}/library");
      ignoreDir = [
        ".git"
        ".github"
        ".direnv"
        "result"
        "nix"
        "doc"
      ];
    };
    diagnostics = {
      libraryFiles = "Disable";
      globals = ["vim"];
      disable = disabled-diagnostics;
    };
    format.defaultConfig = {
      # see https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
      align_array_table = "false";
      align_function_params = "false";
      align_continuous_rect_table_field = "false";
      align_continuous_assign_statement = "false";
    };
  };
in
  (pkgs.formats.json {}).generate ".luarc.json" luarc
