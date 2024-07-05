{pkgs, ...}: let
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
  imports = [
    ../common/apps.nix
  ];

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
    gnome-control-center
    gnome.gnome-weather
    shikane
  ];

  xdg.configFile."ags" = {
    source = ./ags;
    recursive = true;
  };

  # Keycodes here: https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h#L202
  # :1 is for keydown, :0 for keyup
  xdg.configFile."fusuma/config.yaml".text = ''
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
      4:
          command: 'ydotool key 125:1 52:1 52:0 125:0'
  '';

  xdg.configFile."shikane/config.toml".text = ''
    [[profile]]
    name = "laptop"
        [[profile.output]]
        match = "eDP-1"
        enable = true


    [[profile]]
    name = "docked"
    exec = ["bash -c 'ags -q; cat /proc/$(pidof dwl)/fd/1 | ags & disown'"]
        [[profile.output]]
        match = "eDP-1"
        enable = false

        [[profile.output]]
        match = "/DP-2|.*|EB243Y A/"
        enable = true
        mode = { width = 1920, height = 1080, refresh = 60 }
        position = { x = 0, y = 0 }
        scale = 1

        [[profile.output]]
        match = "/DP-1|.*|EB243Y A/"
        enable = true
        mode = { width = 1920, height = 1080, refresh = 60 }
        position = { x = 0, y = 1180 }
        scale = 1

  '';
}
