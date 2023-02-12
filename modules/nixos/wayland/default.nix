{
  lib,
  config,
  ...
}: let
  cfg = config.modules.wayland;
in {
  options.modules.wayland = {enable = lib.mkEnableOption "wayland";};
  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    security.rtkit.enable = true;
    security.polkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
