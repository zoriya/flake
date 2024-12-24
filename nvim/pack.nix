{
  pkgs,
  lib,
  ...
}: {
  packPlugins = plugins: let
    # Set option value with default priority so that values are appended by default
    pathsToLink = [
      # :h rtp
      "/autoload"
      "/colors"
      "/compiler"
      "/doc"
      "/ftplugin"
      "/indent"
      "/keymap"
      "/lang"
      "/lua"
      "/pack"
      "/parser"
      "/plugin"
      "/queries"
      "/rplugin"
      "/spell"
      "/syntax"
      "/tutor"
      "/after"
      "/ftdetect"
      # plenary.nvim
      "/data/plenary/filetypes"
    ];

    # Every plugin has its own generated help tags (doc/tags)
    # Remove them to avoid collisions, new help tags
    # will be generate for the entire pack later on
    overriddenPlugins =
      map (
        plugin:
          plugin.plugin.overrideAttrs (prev: {
            nativeBuildInputs = lib.remove pkgs.vimUtils.vimGenDocHook prev.nativeBuildInputs or [];
            configurePhase = ''
              ${prev.configurePhase or ""}
              rm -vf doc/tags'';
          })
      )
      plugins;

    # Python3 dependencies
    python3Dependencies = let
      deps = map (p: p.plugin.python3Dependencies or (_: [])) plugins;
    in
      ps: builtins.concatMap (f: f ps) deps;

    # Combined plugin
    combinedPlugin = pkgs.vimUtils.toVimPlugin (
      pkgs.buildEnv {
        name = "plugin-pack";
        paths = overriddenPlugins;
        inherit pathsToLink;
        # Remove empty directories and activate vimGenDocHook
        postBuild = ''
          find $out -type d -empty -delete
          runHook preFixup
        '';
        passthru = {
          inherit python3Dependencies;
        };
      }
    );

    # Combined plugin configs
    combinedConfig = builtins.concatStringsSep "\n" (
      builtins.concatMap (x: lib.optional (x.config != null && x.config != "") x.config) plugins
    );
  in {
    plugin = combinedPlugin;
    config = combinedConfig;
    optional = false;
  };
}
