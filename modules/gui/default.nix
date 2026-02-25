{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs;
    lib.optionals pkgs.stdenv.isx86_64 [
      wineWow64Packages.stable
      wineWow64Packages.waylandFull
      winetricks
    ];
  programs.gamescope = {
    enable = true;
    capSysNice = true;
    args = [
      "--steam"
      "--hdr-enabled"
      "--adaptive-sync"
      "--fullscreen"
      "--expose-wayland"
    ];
  };
  hardware.steam-hardware.enable = true;
  services.flatpak.enable = true;

  # i lost way too much time understanding why my local server/app can't be reached
  networking.firewall.enable = false;
}
