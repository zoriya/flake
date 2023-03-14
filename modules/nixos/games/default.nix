{ pkgs, config, lib, ... }: let
cfg = config.games;
in {
  options.games = { enable = lib.mkEnableOption "games"; };
  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;

    hardware.steam-hardware.enable = true;
    hardware.opengl.driSupport32Bit = true;
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      wineWowPackages.waylandFull
      winetricks
    ];
  };
}
