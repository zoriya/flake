{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      hide_window_decorations = "yes";

      enable_audio_bell = false;
      cursor_blink_interval = 0;
      confirm_os_window_close = 0;
      disable_ligatures = "always";
      #placement_strategy bottom-center

      tab_bar_min_tabs = 3;
      tab_bar_style = "separator";
      tab_bar_edge = "top";
      dynamic_background_opacity = true;
    };
    # Use ghostty one instead
    shellIntegration.enableZshIntegration = false;

    extraConfig = ''
      clear_all_shortcuts yes
      kitty_mod alt
      map ctrl+shift+c copy_to_clipboard
      map ctrl+shift+v paste_from_clipboard

      map ctrl+equal change_font_size current +2.0
      map ctrl+plus change_font_size current +2.0
      map ctrl+minus change_font_size current -2.0
      map ctrl+backspace change_font_size current 0

      map kitty_mod+e scroll_line_up
      map kitty_mod+y scroll_line_down

      map kitty_mod+o scroll_to_prompt -1
      map kitty_mod+i scroll_to_prompt 1
      map kitty_mod+space show_last_command_output

      cursor_shape beam
      include light.conf
      include theme.conf
    '';
  };

  xdg.configFile."kitty/light.conf".source = "${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Latte.conf";
  xdg.configFile."kitty/dark.conf".source = "${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Mocha.conf";

  # programs.zsh.shellAliases = {
  #   ssh = "kitty +kitten ssh";
  # };
}

