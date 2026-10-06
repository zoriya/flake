{
  pkgs,
  opencode,
  ...
}: {
  programs.opencode = {
    enable = true;
    package = opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    rules = ./global.md;
  };

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    update = "disable";
    agents.title.model = "github-copilot/gpt-5-mini";
    plugins = ["@mohak34/opencode-notifier"];
  };

  xdg.configFile."opencode/cli.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/v2/cli.json";
    theme.name = "catppuccin";
    diffs.view = "unified";
    keybinds = {
      "variant.cycle" = "ctrl+n";
      "prompt.clear" = "ctrl+u";
      "session.interrupt" = "ctrl+d";
      "app.exit" = "<leader>q";
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
