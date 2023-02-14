{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = {enable = lib.mkEnableOption "hyprland";};
  config =
    lib.mkIf cfg.enable
    {
      home.packages = with pkgs; [nur.repos.ocfox.swww];
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

      # TODO: zsh alias for wp
    };
}
