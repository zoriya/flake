{
  pkgs,
  user,
  lib,
  ...
}: {
  imports = [
    ../../modules/wm
    ../../modules/gui
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd zsh";
        user = "greeter";
      };
      initial_session = {
        command = "${lib.getExe pkgs.uwsm} start -S hyprland-uwsm.desktop";
        user = user;
      };
    };
  };

  xdg.portal = {
    enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
  };
}
