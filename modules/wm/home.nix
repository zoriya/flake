{
  pkgs,
  lib,
  ...
}: let
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

  toml = pkgs.formats.toml {};
in {
  imports = [
    ./rofi
    ./fcitx5.nix
  ];
  home.packages = with pkgs; [
    screenshot
    screenshot-freeze
    record
    libnotify
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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-blink = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
    };
  };

  xdg.configFile."noctalia/config.toml".source = toml.generate "toml" {
    shell = {
      show_location = true;
      avatar_path = "~/.face";
      clipboard_auto_paste = "off";
      polkit_agent = true;

      panel = {
        background_blur = true;
        attach_control_center = true;
        attach_wallpaper = true;
      };

      screen_corners = {
        enabled = false;
        size = 32;
      };
    };

    osd.position = "bottom_center";

    notification = {
      enable_daemon = true;
      position = "top_right";
      layer = "top";
      background_opacity = 0.97;
    };

    bar.order = ["main"];

    bar.main = {
      position = "top";
      enabled = true;
      auto_hide = false;
      reserve_space = true;
      thickness = 34;
      background_opacity = 1.0;
      shadow = true;
      radius = 0;
      margin_ends = 0;
      margin_edge = 0;
      padding = 14;
      widget_spacing = 6;
      capsule = true;
      capsule_opacity = 0.5;
      attach_panels = true;

      start = ["taskbar"];
      center = ["notifications" "clipboard"];
      end = ["media" "spacer" "battery" "volume" "bluetooth" "network" "spacer" "clock"];
    };

    widget.taskbar = {
      type = "taskbar";
      display = "none";
      group_by_workspace = true;
    };

    widget.notifications = {
      type = "notifications";
      hide_when_no_unread = true;
    };

    widget.media = {
      type = "media";
      min_length = 80;
      max_length = 250;
      art_size = 16;
      title_scroll = "none";
    };

    widget.spacer = {
      type = "spacer";
      length = 8;
    };

    widget.tray = {
      type = "tray";
      drawer = false;
    };

    widget.battery = {
      type = "battery";
      device = "auto";
    };

    widget.volume = {
      type = "volume";
      device = "output";
      show_label = true;
    };

    widget.bluetooth = {
      type = "bluetooth";
      show_label = false;
    };

    widget.network = {
      type = "network";
      show_label = false;
    };

    widget.clock = {
      type = "clock";
      format = "{:%H:%M}\n{:%Y-%m-%d}";
    };

    theme = {
      mode = "auto";
      source = "builtin";
      builtin = "Catppuccin";
    };

    backdrop = {
      enabled = true;
      blur_intensity = 0.5;
      tint_intensity = 0.3;
    };

    nightlight.enabled = false;

    audio = {
      enable_overdrive = true;
      enable_sounds = false;
    };

    idle.behavior.lock = {
      timeout = 660;
      command = "noctalia:screen-lock";
      enabled = true;
    };

    idle.behavior.screen-off = {
      timeout = 600;
      command = "noctalia:dpms-off";
      resume_command = "noctalia:dpms-on";
    };

    desktop_widgets.enabled = false;

    wallpaper.directory = "~/wallpapers";

    weather.auto_locate = true;
  };
}
