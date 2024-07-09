{pkgs, ...}: let
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

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 3;
        ignore_emauthpty_input = true;
      };
      background = {
        monitor = "";
        path = "/home/zoriya/.cache/current-wallpaper";
      };
      input-field = {
        monitor = "";
        size = "250, 50";
        outline_thickness = 0;
        dots_size = 0.26;
        inner_color = "#ff0000";
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
          color = "#ff0000";

          font_size = 64;
          font_family = "monospace";

          position = "0, -70";
          halign = "center";
          valign = "center";
        }

        {
          monitor = "";
          text = ''cmd[update:18000000] echo "<b> "$(${pkgs.coreutils}/bin/date +'%A, %-d %B %Y')" </b>"'';
          color = "#ff0000";

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
          timeout = 1800;
          on-timeout = "${pkgs.procps}/bin/pidof hyprlock && ${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };
}
