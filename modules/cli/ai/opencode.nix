{...}: {
  programs.opencode = {
    enable = true;
    settings = {
      small_model = "github-copilot/gpt-5-mini";
      autoupdate = false;
      plugin = ["@mohak34/opencode-notifier"];
    };
    tui = {
      theme = "catppuccin";
      diff_style = "stacked";
      keybinds = {
        variant_cycle = "ctrl+n";
        input_clear = "ctrl+u";
        session_interrupt = "ctrl+d";
        app_exit = "<leader>q";
        input_submit = "ctrl+s";
        input_newline = "return";
        input_undo = "ctrl+y,ctrl+z";
        input_redo = "ctrl+shift+y,ctrl+shift+z";
        terminal_suspend = "none";
      };
    };
  };

  xdg.configFile."opencode/opencode-notifier.json".text = builtins.toJSON {
    sound = false;
    showSessionTitle = true;
  };
}
