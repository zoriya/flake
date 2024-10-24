{pkgs, ...}: {
  imports = [
    ../../modules/wm
  ];

  # this is called manually in the river init script.
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd zsh";
        user = "greeter";
      };
      initial_session = {
        # zsh -c is to give river access to profile variables
        command = "${pkgs.systemd}/bin/systemctl --wait --user start river.service";
        user = "zoriya";
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
  };

  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
  ];
  hardware.steam-hardware.enable = true;
  programs.gamescope.enable = true;
  services.flatpak.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
