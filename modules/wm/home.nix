{
  pkgs,
  lib,
  noctalia,
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
    ./fcitx5.nix
    ./hyprlock.nix
    noctalia.homeModules.default
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

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {
      bar = {
        capsuleOpacity = 0.5;
        showCapsule = false;
        outerCorners = false;
        widgets = {
          left = [
            {
              id = "TaskbarGrouped";
              labelMode = "none";
            }
          ];
          center = [
            {
              id = "NotificationHistory";
            }
          ];
          right = [
            {
              id = "MediaMini";
              maxWidth = 250;
              showArtistFirst = false;
            }
            {
              id = "Spacer";
            }
            {
              id = "Tray";
            }
            {
              id = "Battery";
              displayMode = "alwaysShow";
              warningThreshold = 30;
            }
            {
              id = "Volume";
              displayMode = "alwaysHide";
            }
            {
              id = "Bluetooth";
              displayMode = "alwaysHide";
            }
            {
              id = "WiFi";
              displayMode = "alwaysHide";
            }
            {
              id = "Spacer";
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm\\nyyyy-MM-dd";
            }
          ];
        };
      };
      controlCenter = {
        position = "top_center";
      };
      audio.visualizerType = "none";
      notifications = {
        enabled = true;
        location = "bar";
        lowUrgencyDuration = 3;
        normalUrgencyDuration = 3;
        criticalUrgencyDuration = 3;
      };
      osd = {
        enabled = true;
        location = "bottom";
      };
      sessionMenu = {
        enableCountdown = false;
        powerOptions = [
          {
            action = "lock";
            enabled = true;
          }
          {
            action = "suspend";
            enabled = true;
          }
          {
            action = "hibernate";
            enabled = false;
          }
          {
            action = "reboot";
            enabled = true;
          }
          {
            action = "logout";
            enabled = false;
          }
          {
            action = "shutdown";
            enabled = true;
          }
        ];
        showHeader = true;
      };
      screenRecorder.directory = "~/stuff";
      settingsVersion = 23;
      setupCompleted = true;
      general = {
        lockOnSuspend = false;
        showScreenCorners = false;
      };
      colorSchemes = {
        predefinedScheme = "Catppuccin";
      };
      wallpaper.enabled = false;
      dock.enabled = false;
      nightLight.enabled = false;
    };
  };
}
