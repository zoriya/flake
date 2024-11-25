{pkgs, user, ...}: let
  wallpaper = pkgs.writeShellScriptBin "wallpaper" ''
    WALLPAPERS=~/wallpapers/

    WP=$(find $WALLPAPERS -type f | shuf -n 1)
    ln -fs "$WP" ~/.cache/current-wallpaper

    ${pkgs.wbg}/bin/wbg "$WP" > /dev/null 2> /dev/null & disown
    echo "$WP"
  '';
in {
  imports = [
    ./rofi
    ./ags
  ];
  home.packages = [
    wallpaper
  ];

  services.darkman = let
    genTheme = theme: {
      color-scheme = "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme prefer-${theme}";
      gtk3 = let
        suffix =
          if theme == "light"
          then ""
          else "-dark";
      in "${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3${suffix}";
      kit = ''
        ${pkgs.coreutils}/bin/ln -sf $XDG_CONFIG_HOME/kitty/${theme}.conf $XDG_CONFIG_HOME/kitty/theme.conf
        ${pkgs.procps}/bin/pkill -USR1 kitty
      '';
    };
  in {
    enable = true;
    settings = {
      usegeoclue = true;
    };
    lightModeScripts = genTheme "light";
    darkModeScripts = genTheme "dark";
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 3;
        ignore_empty_input = true;
        immediate_render = true;
      };
      background = {
        monitor = "";
        path = "/home/${user}/.cache/current-wallpaper";
      };
      input-field = {
        monitor = "";
        size = "250, 50";
        outline_thickness = 0;
        dots_size = 0.26;
        dots_spacing = 0.64;
        dots_center = true;
        fade_on_empty = true;
        placeholder_text = "<i>Password...</i>";
        hide_input = false;
        check_color = "rgb(40, 200, 250)";
        position = "0, 50";
        halign = "center";
        valign = "bottom";
      };
      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<b><big> $(${pkgs.coreutils}/bin/date +"%H:%M") </big></b>"'';

          font_size = 64;
          font_family = "monospace";

          position = "0, -70";
          halign = "center";
          valign = "center";
        }

        {
          monitor = "";
          text = ''cmd[update:18000000] echo "<b> "$(${pkgs.coreutils}/bin/date +'%A, %-d %B %Y')" </b>"'';

          font_size = 24;
          font_family = "monospace";

          position = "0, -120";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
      };

      listener = [
        {
          timeout = 900; # 15min
          on-timeout = "${pkgs.procps}/bin/pidof hyprlock && ${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };
  systemd.user.services.fcitx5-daemon = {
    Unit = {
      After = ["graphical-session.target"];
    };
  };

  xdg.configFile."fcitx5/config" = {
    force = true;
    text = ''
      [Hotkey/TriggerKeys]
      0=Super+space

      [Behavior]
      ShowInputMethodInformation=False
      CompactInputMethodInformation=False
      ShowFirstInputMethodInformation=False
    '';
  };
  xdg.configFile."fcitx5/profile" = {
    force = true;
    text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=mozc

      [Groups/0/Items/0]
      Name=keyboard-us
      Layout=

      [Groups/0/Items/1]
      Name=mozc
      Layout=

      [GroupOrder]
      0=Default
    '';
  };
}
