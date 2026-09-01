{
  pkgs,
  lib,
  noctalia,
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
in {
  imports = [
    ./fcitx5.nix
    noctalia.homeModules.default
  ];
  home.packages = with pkgs; [
    screenshot
    screenshot-freeze
    record
    libnotify
    socat
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

  xdg.dataFile."noctalia/plugins/notif-inline".source = ./noctalia/notif-inline;

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      plugins.enabled = ["zoriya/notif-inline"];

      # no toasts, the notif-inline plugin renders them in the bar instead
      notification.filter.inline = {
        match_content = ".*";
        show_toast = false;
        save_history = true;
        allow_permanent = false;
      };

      shell = {
        avatar_path = "~/.face";
        clipboard_auto_paste = "off";
        clipboard_history_max_entries = 10000;
        launch_apps_as_systemd_services = true;
        polkit_agent = true;
        setup_wizard_enabled = false;
        panel.transparency_mode = "glass";
        panel.open_near_click_control_center = true;
        session.show_shortcuts = false;
      };

      osd = {
        position = "bottom_center";
        kinds.media = false;
      };

      control_center.sidebar_section = "none";

      bar.main = {
        radius = 0;
        margin_ends = 0;
        background_opacity = 0.75;
        capsule = true;
        capsule_opacity = 0.5;

        start = ["taskbar"];
        center = ["zoriya/notif-inline:bar"];
        end = ["media" "spacer" "tray" "privacy" "battery" "volume" "bluetooth" "network" "spacer" "clock"];
      };

      widget = {
        taskbar = {
          group_by_workspace = true;
          show_workspace_label = false;
          inactive_opacity = 0.8;
        };
        notifications.hide_when_no_unread = true;
        media = {
          max_length = 250;
          show_progress = true;
          hide_when_no_media = true;
        };
        tray.drawer = true;
        privacy.hide_inactive = true;
        spacer.length = 20;
        network.show_label = false;
        clock = {
          format = "{:%H:%M}\n{:%Y-%m-%d}";
          font_weight = 700;
        };
      };

      battery.warning_threshold = 20;

      theme = {
        mode = "auto";
        source = "builtin";
        builtin = "Catppuccin";
      };

      backdrop.enabled = true;

      audio.enable_overdrive = true;

      desktop_widgets.enabled = false;

      idle.behavior.suspend = {
        timeout = 0;
        locked_timeout = 600;
        action = "suspend";
        lock_before_suspend = false;
      };

      wallpaper = {
        directory = "~/wallpapers";
        automation = {
          enabled = true;
          interval_seconds = 3600;
        };
      };
      location.auto_locate = true;
    };
  };
}
