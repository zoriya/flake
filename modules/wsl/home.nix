{lib, ...}: {
  imports = [
    # Install apps that I open with wslg (and tools like wl-clipboard which works)
    ../common/apps.nix
  ];

  gtk.enable = lib.mkForce false;
  services.xsettingsd.enable = lib.mkForce false;
  qt.enable = lib.mkForce false;

  home.sessionVariables = {
    WAYLAND_DISPLAY = "wayland-0";
  };

}
