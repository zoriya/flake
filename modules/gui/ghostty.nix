{
  ghostty,
  pkgs,
  ...
}: {
  programs.ghostty = {
    enable = true;
    package = ghostty.packages.${pkgs.system}.default;
    enableZshIntegration = true;
    clearDefaultKeybinds = true;
    settings = {
      font-size = 12;
      font-feature = "-calt";
      freetype-load-flags = false;
      font-style = "semibold";

      theme = "light:catppuccin-latte,dark:catppuccin-mocha";
      # disabling cursor because it sets it to blink and i hate that
      shell-integration-features = "no-cursor,sudo,title";
      cursor-style-blink = false;

      window-padding-x = 0;
      window-padding-y = 0;
      window-padding-balance = true;
      window-padding-color = "extend";

      window-decoration = false;
      adw-toast = false;
      confirm-close-surface = false;
      resize-overlay = "never";
      # avoid dreadfully long startup times
      gtk-single-instance = true;
      auto-update = "off";
      unfocused-split-opacity = 1;

      clipboard-read = "allow";
      copy-on-select = false;

      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "cmd+c=copy_to_clipboard"
        "cmd+v=paste_from_clipboard"

        "ctrl+plus=increase_font_size:1"
        "ctrl+equal=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+zero=reset_font_size"
        "ctrl+backspace=reset_font_size"

        "ctrl+shift+comma=reload_config"
        "ctrl+shift+i=inspector:toggle"
      ];
    };
  };
}
