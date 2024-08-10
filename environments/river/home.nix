{
  pkgs,
  config,
  ...
}: let
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [pkgs.slurp pkgs.grim];
    text = ''
      grim -g "$(slurp -b 00000000 -s 61616140)" - | wl-copy
    '';
  };

  common_binds = {
    "None XF86AudioRaiseVolume" = "spawn '${pkgs.pamixer}/bin/pamixer -i 5'";
    "None XF86AudioLowerVolume" = "spawn '${pkgs.pamixer}/bin/pamixer  -d 5'";
    "None XF86AudioMute" = "spawn '${pkgs.pamixer}/bin/pamixer  --toggle-mute'";
    "None XF86AudioMedia" = "spawn '${pkgs.playerctl}/bin/playerctl play-pause'";
    "None XF86AudioPlay" = "spawn '${pkgs.playerctl}/bin/playerctl  play-pause'";
    "None XF86AudioPause" = "spawn '${pkgs.playerctl}/bin/playerctl  play-pause'";
    "None XF86AudioPrev" = "spawn '${pkgs.playerctl}/bin/playerctl playerctl previous'";
    "None XF86AudioNext" = "spawn '${pkgs.playerctl}/bin/playerctl playerctl next'";
    "None XF86MonBrightnessUp" = "spawn '${pkgs.brightnessctl}/bin/brightnessctl s +5%'";
    "None XF86MonBrightnessDown" = "spawn '${pkgs.brightnessctl}/bin/brightnessctl s 5%-'";
  };
in {
  imports = [
    ../../modules/gui
    ../../modules/wm/home.nix
  ];
  services.cliphist.enable = true;

  xdg.configFile."river-luatile/layout.lua".source = ./layout.lua;

  wayland.windowManager.river = {
    enable = true;
    extraSessionVariables = {
      XDG_CURRENT_DESKTOP = "river";
    };
    settings = {
      default-layout = "luatile";
      spawn = [
        "${pkgs.river-luatile}/bin/river-luatile"
        "wallpaper"
        "ags"
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
      keyboard-layout = "-options 'caps:escape_shifted_capslock' us";
      input = {
        "'*'" = {
          events = true;
          accel-profile = "adaptive";
          pointer-accel = 0;
          click-method = "button-areas";
          tap = true;
          drag = true;
          disable-while-typing = true;
          middle-emulation = true;
          natural-scroll = true;
          tap-button-map = "left-right-middle";
          scroll-method = "two-finger";
        };
        "'*Mouse'" = {
          natural-scroll = "disabled";
        };
      };

      border-color-focused = "0x94e2d5";
      border-color-unfocused = "0x00000000";
      border-color-urgent = "0xcba6f7";
      border-width = 2;

      rule-add = {
        "-app-id" = {
          "discord" = "tags $((1 << 2))";
          "'YouTube Music'" = "tags $((1 << 1))";
          # disable all client side decorations
          "'*'" = "ssd";
        };
      };

      declare-mode = ["normal" "locked" "passthrough"];
      map = {
        normal =
          {
            "Super+Shift Q" = "exit";
            "Super C" = "close";

            "Super K" = "focus-view next";
            "Super J" = "focus-view previous";
            "Super+Shift K" = "swap previous";
            "Super+Shift J" = "swap previous";
            "Super Return" = "zoom";

            "Super Period" = "focus-output next";
            "Super Comma" = "focus-output previous";
            "Super+Shift Period" = "send-to-output -current-tags next";
            "Super+Shift Comma" = "send-to-output -current-tags previous";

            "Super H" = "send-layout-cmd luatile 'set_mfact(-0.05)'";
            "Super L" = "send-layout-cmd luatile 'set_mfact( 0.05)'";
            "Super U" = "send-layout-cmd luatile 'set_mcount(-1)'";
            "Super I" = "send-layout-cmd luatile 'set_mcount( 1)'";

            "Super T" = "send-layout-cmd luatile 'set_layout(\"tiling\")'";
            "Super M" = "send-layout-cmd luatile 'set_layout(\"monocle\")'";
            "Super D" = "send-layout-cmd luatile 'set_layout(\"deck\")'";
            "Super F" = "toggle-fullscreen";
            "Super+Shift F" = "toggle-float";

            "Super R" = "spawn ${config.home.sessionVariables.BROWSER}";
            "Super E" = "spawn ${config.home.sessionVariables.TERMINAL}";
            "Super P" = "spawn 'rofi -show drun -show-icons'";
            "Super X" = "spawn '${screenshot}/bin/screenshot'";
            "Super B" = "spawn '${pkgs.hyprpicker}/bin/hyprpicker | wl-copy'";
            "Super V" = "spawn '${cliphist} list | rofi -dmenu -display-columns 2 | ${cliphist} decode | wl-copy'";
            "Super+Shift L" = "spawn 'loginctl lock-session'";

            "Super+Shift Backslash" = "enter-mode passthrough";
          }
          // common_binds;
        locked = common_binds;
        passthrough = {
          "Super+Shift Backslash" = "enter-mode normal";
        };
      };
      map-pointer = {
        normal = {
          "Super+Shift BTN_LEFT" = "move-view";
          "Super+Shift BTN_RIGHT" = "resize-view";
        };
      };
    };
    extraConfig = ''
      for i in $(seq 1 9)
      do
          tags=$((1 << (i - 1)))
          riverctl map normal Super "$i" set-focused-tags -alternate $tags
          riverctl map normal Super+Shift "$i" set-view-tags $tags
          riverctl map normal Super+Control "$i" toggle-focused-tags $tags
          riverctl map normal Super+Shift+Control "$i" toggle-view-tags $tags
      done

      all_tags=$(((1 << 32) - 1))
      riverctl map normal Super 0 set-focused-tags -alternate "$all_tags"
      riverctl map normal Super+Shift 0 set-view-tags "$all_tags"

      # Focus second screen by default (also spawn apps there)
      riverctl focus-output DP-1
      riverctl set-focused-tags "$all_tags"
      riverctl focus-output DP-2
      riverctl set-focused-tags $((1 << 3))

      hyprlock --immediate
    '';

    systemd = {
      enable = true;
      runInService = true;
      extraCommands = [
        "${pkgs.systemd}/bin/systemctl --user start xdg-autostart-if-no-desktop-manager.target"
      ];
    };
  };

  # Run river in systemd directly and not by hand. Failing to do so will make graphical-session.target never stop.
  # So a big wait time when shutting down & graphical services are not restarted when starting river again.

  home.packages = with pkgs; [
    gnome-control-center
    gnome.gnome-weather
    wdisplays
  ];

  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        output.criteria = "eDP-1";
        output.scale = 1.75;
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-1";
            position = "0,0";
          }
          {
            criteria = "DP-2";
            position = "0,1180";
          }
        ];
      }
    ];
  };

  # Disable close/resize buttons on GTK windows that really want CSD.
  # gsettings set org.gnome.desktop.wm.preferences button-layout ""
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
    };
  };
}
