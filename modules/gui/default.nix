{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
  ];
  hardware.steam-hardware.enable = true;
  services.flatpak.enable = true;
}
