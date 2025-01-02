{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      font_size = 12;
      cursor_shape = "beam";
      hide_window_decorations = "yes";

      enable_audio_bell = false;
      cursor_blink_interval = 0;
      confirm_os_window_close = 0;
      disable_ligatures = "always";
      placement_strategy = "bottom";
    };
    # Use ghostty one instead
    shellIntegration.enableZshIntegration = false;

    extraConfig = ''
      clear_all_shortcuts yes
      map ctrl+shift+c copy_to_clipboard
      map ctrl+shift+v paste_from_clipboard

      map ctrl+equal change_font_size current +1.0
      map ctrl+plus change_font_size current +1.0
      map ctrl+minus change_font_size current -1.0
      map ctrl+backspace change_font_size current 0
    '';
  };

  xdg.configFile."kitty/light-theme.auto.conf".source = "${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Latte.conf";
  xdg.configFile."kitty/dark-theme.auto.conf".source = "${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Mocha.conf";
  xdg.configFile."kitty/no-preference-theme.auto.conf".source = "${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Mocha.conf";
}

