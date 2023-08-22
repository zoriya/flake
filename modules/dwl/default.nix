{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      autoLogin = {
        enable = true;
        user = "zoriya";
      };
      sessionPackages = [ pkgs.dwl ];
    };
  };

  environment.systemPackages = [pkgs.dwl];

  # Those two lines prevent a crash with gdm autologin.
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.upower.enable = true;

  # i18n.inputMethod.enabled = "ibus";
  # i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [mozc];
}
