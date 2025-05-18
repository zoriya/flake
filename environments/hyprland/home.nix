{pkgs, ...}: {
  imports = [
    ../../modules/gui/home.nix
    ../../modules/wm/home.nix
  ];
  services.hyprpolkitagent.enable = true;

  home.packages = with pkgs; [
    pamixer
    brightnessctl
    playerctl
    hyprpicker

    gnome-control-center
    gnome-weather
    wdisplays
  ];

  xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;

  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   extraSessionVariables = {
  #     XDG_CURRENT_DESKTOP = "river";
  #   };
  #   settings = {
  #     default-layout = "luatile";
  #     spawn = [
  #       "${pkgs.river-luatile}/bin/river-luatile"
  #       "wallpaper"
  #       "ags"
  #     ];
  #
  #     input = {
  #       "'*'" = {
  #         pointer-accel = 0;
  #         scroll-method = "two-finger";
  #       };
  #     };
  #
  #     # border-color-focused = "0x94e2d5";
  #     # border-color-unfocused = "0x00000000";
  #     # border-color-urgent = "0xcba6f7";
  #
  #     map = {
  #       normal = {
  #         # "Super+Shift Period" = "send-to-output -current-tags next";
  #         # "Super+Shift Comma" = "send-to-output -current-tags previous";
  #         # "Super+Control+Shift Period" = "send-to-output next";
  #         # "Super+Control+Shift Comma" = "send-to-output previous";
  #
  #         "Super T" = "send-layout-cmd luatile 'set_layout(\"tiling\")'";
  #         "Super M" = "send-layout-cmd luatile 'set_layout(\"monocle\")'";
  #         "Super D" = "send-layout-cmd luatile 'set_layout(\"deck\")'";
  #       };
  #     };
  #     map-pointer = {
  #       normal = {
  #         "Super+Shift BTN_LEFT" = "move-view";
  #         "Super+Shift BTN_RIGHT" = "resize-view";
  #       };
  #     };
  #   };
  #   extraConfig = ''
  #     for i in $(seq 1 9)
  #     do
  #         tags=$((1 << (i - 1)))
  #         riverctl map normal Super "$i" set-focused-tags -alternate $tags
  #         riverctl map normal Super+Shift "$i" set-view-tags $tags
  #         riverctl map normal Super+Control "$i" toggle-focused-tags $tags
  #         riverctl map normal Super+Shift+Control "$i" toggle-view-tags $tags
  #     done
  #
  #     all_tags=$(((1 << 32) - 1))
  #     riverctl map normal Super 0 set-focused-tags -alternate "$all_tags"
  #     riverctl map normal Super+Shift 0 set-view-tags "$all_tags"
  #
  #     # Focus second screen by default (also spawn apps there)
  #     riverctl focus-output DP-1
  #     riverctl set-focused-tags $((1 << 3))
  #
  #     hyprlock --immediate
  #   '';
  # };

  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        output.criteria = "eDP-1";
        output.scale = 1.6;
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
            criteria = "Dell Inc. DELL S2722QC 2HHZH24";
            # position = "1500,0";
            position = "0,900";
            scale = 1.7;
          }
          {
            criteria = "*";
            position = "0,0";
            scale = 1.4;
          }
        ];
      }
    ];
  };
}
