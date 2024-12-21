{
  pkgs,
  user,
  lib,
  ...
}: {
  imports = [
    ../../modules/wm
  ];

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      river = {
        prettyName = "river";
        comment = "river compositor managed by UWSM";
        binPath = "${pkgs.river}/bin/river";
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd zsh";
        user = "greeter";
      };
      initial_session = {
        command = "uwsm start -S river-uwsm.desktop";
        user = user;
      };
    };
  };

  # Without this, greetd would depend on graphical.target & would get activated before
  # uwsm. This leads to a race that can:
  #  - fail startup & retry it (leading to a ~10s delay)
  #  - make graphical services start before river.
  # To prevent those issue, simply target the default tty & greetd's inital_session will
  # start uwsm & end up reaching graphical.target
  systemd.defaultUnit = lib.mkForce "multi-user.target";


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
