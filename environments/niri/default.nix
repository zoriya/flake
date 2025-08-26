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

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      niri = {
        prettyName = "niri";
        comment = "niri compositor managed by UWSM";
        binPath = "${pkgs.niri}/bin/niri";
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd zsh";
        user = "greeter";
      };
      initial_session = {
        command = "${lib.getExe pkgs.uwsm} start -S niri-uwsm.desktop";
        user = user;
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
    ];
    config.common.default = "*";
    configPackages = with pkgs; [niri];
  };
}
