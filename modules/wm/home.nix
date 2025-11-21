{
  pkgs,
  lib,
  ...
}: let
  wallpaper = pkgs.writeShellScriptBin "wallpaper" ''
    WALLPAPERS=~/wallpapers/

    WP=$(find $WALLPAPERS -type f | shuf -n 1)
    ln -fs "$WP" ~/.cache/current-wallpaper

    ${pkgs.wbg}/bin/wbg "$WP" > /dev/null 2> /dev/null & disown
    echo "$WP"
  '';

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [pkgs.slurp pkgs.grim];
    text = ''
      grim -g "$(slurp -b 00000000 -s 61616140)" - | wl-copy
    '';
  };
  screenshot-freeze = pkgs.writeShellApplication {
    name = "screenshot-freeze";
    runtimeInputs = [pkgs.slurp pkgs.grim pkgs.wayfreeze];
    text = ''
      # shellcheck disable=SC2016
      wayfreeze --after-freeze-cmd ''\'grim -g "$(slurp -b 00000000 -s 61616140)" - | wl-copy; killall wayfreeze''\'
    '';
  };
  record = pkgs.writeShellApplication {
    name = "record";
    runtimeInputs = [pkgs.slurp pkgs.wf-recorder];
    text = ''
      pkill wf-recorder && exit
      wf-recorder -g "$(slurp -b 00000000 -s 61616140)" -f "$HOME/rec-$(date +%Y-%m-%d_%H:%M:%S).mp4"
    '';
  };
in {
  imports = [
    ./rofi
    ./quickshell
    ./fcitx5.nix
    ./hyprlock.nix
  ];
  home.packages = [
    wallpaper
    screenshot
    screenshot-freeze
    record
  ];

  services.darkman = let
    genTheme = theme: {
      "0-transition" = "${lib.getExe pkgs.niri} msg action do-screen-transition";
      color-scheme = "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme prefer-${theme}";
      gtk3 = let
        suffix =
          if theme == "light"
          then ""
          else "-dark";
      in "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3${suffix}";
      kubecolor = "echo 'preset: ${theme}' > ~/.kube/color.yaml";
      usql = let
        suffix =
          if theme == "light"
          then "latte"
          else "mocha";
      in "echo 'init: \set SYNTAX_HL_STYLE catppuccin-${suffix}' > ~/.config/usql/config.yaml";
    };
  in {
    enable = true;
    settings = {
      usegeoclue = true;
    };
    lightModeScripts = genTheme "light";
    darkModeScripts = genTheme "dark";
  };

  services.cliphist.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-blink = false;
    };
    # Disable close/resize buttons on GTK windows that really want CSD.
    # gsettings set org.gnome.desktop.wm.preferences button-layout ""
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
    };
  };
}
