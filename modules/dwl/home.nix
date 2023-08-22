{
  pkgs,
  lib,
  config,
  user,
  ...
}: let
  wallpaper = pkgs.writeShellScriptBin "wallpaper" (builtins.readFile ./wallpaper.sh);
in {
  home.packages = with pkgs; [
    alsa-utils
    sassc
    brightnessctl
    pavucontrol
    wbg
    # Only used for pactl.
    pulseaudio
    wallpaper
    hyprpicker
  ];

  xdg.configFile."ags" = {
    source = ./ags;
    recursive = true;
  };

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };
}
