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

      home.file."wallpapers".source = ../../../wallpapers;
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
        size = 16;
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
    };
}
