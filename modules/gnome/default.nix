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
    };
    desktopManager.gnome.enable = true;
  };

  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;

  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [mozc];

  # TODO: Remove this, temporary fix while the extension is not published.
  fileSystems."/home/zoriya/.local/share/gnome-shell/extensions/fairy@zoriya.dev" = {
    device = "/home/zoriya/projects/fairy/";
    fsType = "none";
    options = [ "bind" ];
  };

  environment.systemPackages = with pkgs; [gnome3.gnome-tweaks];
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
      gedit
      epiphany
      geary
      gnome-characters
      tali
      iagno
      hitori
      atomix
      yelp
      gnome-contacts
      gnome-initial-setup
    ]);
}
