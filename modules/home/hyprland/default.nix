{
  pkgs,
  lib,
  config,
  user,
  ...
}: let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = {enable = lib.mkEnableOption "hyprland";};
  config =
    lib.mkIf cfg.enable
    {
      home.packages = with pkgs; [
        nur.repos.ocfox.swww
        xorg.xprop
        discord
        kitty
        grim
        slurp
        wl-clipboard
        pulseaudio
        wob
      ];
      wayland.windowManager.hyprland = {
        enable = true;
        systemdIntegration = true;
        xwayland = {
          enable = true;
          hidpi = true;
        };
        nvidiaPatches = false;
        extraConfig = builtins.readFile ./hyprland.conf;
      };

      home.file.".config/hypr/wallpaper.sh" = {
        source = ./wallpaper.sh;
        executable = true;
      };
      home.file.".config/hypr/start.sh" = {
        source = ./start.sh;
        executable = true;
      };

      home.pointerCursor = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
        size = 24;
        x11 = {
          enable = true;
          defaultCursor = "Adwaita";
        };
      };

      programs.zsh = {
        enable = true;
        loginExtra = ''
          if [ "$(tty)" = "/dev/tty1" ]; then
            exec ~/.config/hypr/start.sh &> /dev/null
          fi
        '';
      };

      xdg.configFile."wob/wob.ini".text = with config.colorScheme.colors; ''
      timeout = 500
      anchor = bottom center
      margin = 200
      output_mode = all
      overflow_mode = wrap
      bar_color = ${base0C}
      overflow_bar_color = ${base08}
      overflow_background_color = ${base01}
      background_color = ${base01}
      border_color = ${base00}
      overflow_border_color = ${base00}
      '';
    };
}
