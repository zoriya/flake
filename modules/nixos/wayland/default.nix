{
  lib,
  config,
  pkgs,
  user,
  ...
}: let
  cfg = config.wayland;
in {
  options.wayland = {enable = lib.mkEnableOption "wayland";};
  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    security.rtkit.enable = true;
    security.polkit.enable = true;

    # Pipewire just refuses to have a decent mic so I will use pulseaudio for now
    # hardware.pulseaudio = {
    #   enable = true;
    #   support32Bit = true;
    # };
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };
    hardware.bluetooth.enable = true;

    security.sudo.extraConfig = ''
      Defaults  lecture="never"
    '';
  };
}
