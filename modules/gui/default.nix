{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs;
    lib.optionals pkgs.stdenv.isx86_64 [
      wineWowPackages.stable
      wineWowPackages.waylandFull
      winetricks
    ];
  hardware.steam-hardware.enable = true;
  services.flatpak.enable = true;

  # i lost way too much time understanding why my local server/app can't be reached
  networking.firewall.enable = false;
}
