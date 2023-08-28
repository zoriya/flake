{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  services.xserver = {
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        settings = {
          "org/gnome/desktop/peripherals/touchpad" = {
            tap-to-click = true;
          };
        };
      };
      autoLogin = {
        enable = true;
        user = "zoriya";
      };
      sessionPackages = [pkgs.dwl];
    };
  };

  environment.systemPackages = with pkgs; [dwl];

  # Those two lines prevent a crash with gdm autologin.
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.dconf.enable = true;
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  services.upower.enable = true;

  # i18n.inputMethod.enabled = "ibus";
  # i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [mozc];
}
