{
  pkgs,
  lib,
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
    package = opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    context = ./global.md;
    settings = {
      update = "disable";
      model = "anthropic/claude-opus-5-5";
      agents.title.model = "anthropic/claude-haiku-5-5";
      websearch = false;
      plugins = [
        "${config.services.meridian.package}/lib/meridian/dist/meridian-v2"
        "@mohak34/opencode-notifier"
        [
          "opencode-goal-plugin@0.11.0"
          {
            # Default is <cwd>/.opencode/goals, which litters every repo.
            stateFilePath = "${config.xdg.stateHome}/opencode/goals/state.json";
          }
        ]
      ];
      providers.anthropic.settings = {
        apiKey = "x";
        baseURL = "http://${config.services.meridian.settings.host}:${toString config.services.meridian.settings.port}/v1";
      };
      providers.anthropic.models.claude-opus-5-5.settings = {
        thinking = {
          type = "adaptive";
          display = "summarized";
        };
        effort = "high";
      };
    };
  };

  # cli.json is installed as a writable file in the activation below instead
  # opencode needs to update it at runtime (e.g. theme mode, thinking toggle).
  home.activation.opencodeWritableCli = lib.hm.dag.entryAfter ["writeBoundary"] ''
    install -Dm644 ${(pkgs.formats.json {}).generate "opencode-cli.json" {
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
    }} "${config.xdg.configHome}/opencode/cli.json"
  '';

  xdg.configFile."opencode/opencode-notifier.json".text = builtins.toJSON {
    sound = false;
    showSessionTitle = true;
  };
}
