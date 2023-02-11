{
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
    };
}
