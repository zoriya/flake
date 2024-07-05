{pkgs, ...}: let
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [pkgs.slurp pkgs.grim];
    text = ''
      grim -g \"$(slurp -b 00000000 -s 61616140)\" - | wl-copy
    '';
  };
in {
  imports = [
    ../common/apps.nix
  ];
  services.cliphist.enable = true;

  wayland.windowManager.river = {
    enable = true;
    settings = {
      default-layout = "rivercarro";
      spawn = [
        "${pkgs.rivercarro}/bin/rivercarro"
        "discord"
        "youtube-music"
      ];

      default-attach-mode = "top";
      focus-follows-cursor = "normal"; # might try "always" if this does not feel right
      set-cursor-warp = "on-focus-change";

      hide-cursor = {
        when-typing = true;
      };
      set-repeat = "25 600";
      keyboard-layout = "-options 'caps:escape_shifted_capslock'";
      input = {
        "*" = {
          events = true;
          accel-profile = "adaptive";
          pointer-accel = 0;
          click-method = "button-areas";
          tap = false;
          drag = true;
          disable-while-typing = true;
          middle-emulation = true;
          natural-scroll = true;
          tap-button-map = "left-right-middle";
          scroll-method = "two-finger";
        };
      };

      rule-add = {
        "-app-id" = {
          "discord" = "tags '2'";
          "YouTube Music" = "tags '1'";
          # disable all client side decorations
          "*" = "ssd";
        };
      };

      map = {
        normal = {
          "Super+Shift Q" = "exit";
          "Super C" = "close";

          "Super K" = "focus-view next";
          "Super J" = "focus-view previous";
          "Super+Shift K" = "swap previous";
          "Super+Shift J" = "swap previous";
          "Super Return" = "zoom";

          "Super Period" = "focus-output next";
          "Super Comma" = "focus-output previous";
          "Super+Shift Period" = "send-to-output next";
          "Super+Shift Comma" = "send-to-output previous";

          "Super H" = "send-layout-cmd rivercarro 'main-ratio -0.05'";
          "Super L" = "send-layout-cmd rivercarro 'main-ratio +0.05'";
          "Super U" = "send-layout-cmd rivercarro 'main-count -1'";
          "Super I" = "send-layout-cmd rivercarro 'main-count +1'";

          "Super T" = "send-layout-cmd rivercarro 'main-location-cycle left,monocle'";
          "Super M" = "send-layout-cmd rivercarro 'main-location-cycle left,monocle'";
          "Super F" = "toggle-fullscreen";
          "Super+Shift F" = "toggle-float";

          "Super+Shift BTN_LEFT" = "move-view";
          "Super+Shift BTN_RIGHT" = "resize-view";

          "Super R" = "spawn $BROWSER";
          "Super E" = "spawn $TERMINAL";
          "Super P" = "spawn 'rofi -show drun -show-icons'";
          "Super X" = "spawn '${screenshot}/bin/screenshot'";
          "Super B" = "spawn '${pkgs.hyperpicker}/bin/hyperpicker | wl-copy'";
          "Super V" = "spawn '${cliphist} list | rofi -dmenu -display-columns 2 | ${cliphist} decode | wl-copy'";
        };
      };
    };
    extraConfig = ''
      for i in $(seq 1 9)
      do
          tags=$((1 << (i - 1)))
          riverctl map normal Super "$i" set-focused-tags $tags
          riverctl map normal Super+Shift "$i" set-view-tags $tags
          riverctl map normal Super+Control "$i" toggle-focused-tags $tags
          riverctl map normal Super+Shift+Control "$i" toggle-view-tags $tags
      done

      all_tags=$(((1 << 32) - 1))
      riverctl map normal Super 0 set-focused-tags "$all_tags"
      riverctl map normal Super+Shift 0 set-view-tags "$all_tags"
    '';
  };

  home.packages = with pkgs; [
    gnome-control-center
    gnome.gnome-weather
    wdisplays
  ];

  services.kanshi = {
    enable = true;
    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            scale = 1.75;
          }
        ];
      };
      docked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-2";
          }
          {
            criteria = "DP-1";
            position = "0,1180";
          }
        ];
      };
    };
  };
}
