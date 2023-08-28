{
  pkgs,
  lib,
  config,
  user,
  ...
}: let
  wallpaper = pkgs.writeShellScriptBin "wallpaper" (builtins.readFile ./wallpaper.sh);
  dwlstartup = pkgs.writeShellScriptBin "dwlstartup" (builtins.readFile ./dwlstartup.sh);
in {
  imports = [./rofi];

  home.packages = with pkgs; [
    alsa-utils
    sassc
    brightnessctl
    pavucontrol
    blueberry
    networkmanagerapplet
    wbg
    glib
    # Only used for pactl.
    pulseaudio
    wallpaper
    dwlstartup
    hyprpicker
    wdisplays
    wlr-randr
    grim
    slurp
    cliphist
  ];

  xdg.systemDirs.data = [
    "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
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
