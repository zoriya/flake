{
  pkgs,
  config,
  opencode,
  meridian,
  ...
}: {
  imports = [meridian.homeModules.default];

  services.meridian = {
    enable = true;
    environment.CLAUDE_CONFIG_DIR = config.programs.claude-code.configDir;
    settings = {
      defaultAgent = "opencode";
      pluginConfig = [
        {path = meridian.legacyPackages.${pkgs.stdenv.hostPlatform.system}.meridianPlugins.opencode-scrub.path;}
      ];
    };
  };

  programs.opencode = {
    enable = true;
    package = opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode.overrideAttrs (old: {
      # Detect jj workspaces as one project and list sessions per project instead of per directory.
      patches = (old.patches or []) ++ [./opencode-jj-project.patch];
    });
    context = ./global.md;
  };

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    update = "disable";
    model = "anthropic/claude-opus-5";
    agents.title.model = "anthropic/claude-haiku-4-5";
    plugins = [
      "${config.services.meridian.package}/lib/meridian/dist/meridian-v2"
      "@mohak34/opencode-notifier"
    ];
    providers.anthropic.settings = {
      apiKey = "x";
      baseURL = "http://${config.services.meridian.settings.host}:${toString config.services.meridian.settings.port}/v1";
    };
  };

  xdg.configFile."opencode/cli.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/v2/cli.json";
    theme.name = "catppuccin";
    diffs.view = "unified";
    tabs.mode = "off";
    keybinds = {
      "variant.cycle" = "ctrl+n";
      "prompt.clear" = "ctrl+u";
      "session.interrupt" = "ctrl+c,ctrl+d";
      "input.submit" = "ctrl+s";
      "input.newline" = "return";
      "input.undo" = "ctrl+y,ctrl+z";
      "input.redo" = "ctrl+shift+y,ctrl+shift+z";
      "terminal.suspend" = "none";
    };
  };

  xdg.configFile."opencode/opencode-notifier.json".text = builtins.toJSON {
    sound = false;
    showSessionTitle = true;
  };
}
