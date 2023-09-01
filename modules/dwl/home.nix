{
  pkgs,
  lib,
  config,
  user,
  ...
}: let
  wallpaper = pkgs.writeShellScriptBin "wallpaper" (builtins.readFile ./wallpaper.sh);
  dwlstartup = pkgs.writeShellScriptBin "dwlstartup" (builtins.readFile ./dwlstartup.sh);
  covercolors = pkgs.stdenv.mkDerivation {
    name = "covercolors";
    dontUnpack = true;
    propagatedBuildInputs = [
      (pkgs.python3.withPackages (pyPkgs:
        with pyPkgs; [
          material-color-utilities
          pillow
        ]))
    ];
    installPhase = "install -Dm755 ${./ags/covercolors.py} $out/bin/covercolors";
  };
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
    covercolors
    ydotool
    fusuma
    gnome.gnome-weather
  ];

  dconf.settings = {
    "org/gnome/shell/weather" = {
      automatic-location = true;
    };
  };

  xdg.systemDirs.data = [
    "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
  ];

  xdg.configFile."ags" = {
    source = ./ags;
    recursive = true;
  };

  xdg.configFile."fusuma/config.yaml".text = "
swipe:
  3:
    right:
      command: 'ydotool key 125:1 105:1 105:0 125:0'
    left:
      command: 'ydotool key 125:1 106:1 106:0 125:0'
    up:
      command: 'ydotool key 125:1 4:1 4:0 125:0'
    down:
      command: 'ydotool key 125:1 4:1 4:0 125:0'
hold:
  3:
      command: 'ydotool key 125:1 3:1 3:0 125:0'
";
}
