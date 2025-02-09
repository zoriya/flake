{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./fonts.nix
  ];

  networking.networkmanager.enable = true;
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        # enable battery reporting
        Experimental = true;
      };
    };
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  # See https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2669
  services.pipewire.wireplumber.extraConfig = {
    "10-disable-camera" = {
      "wireplumber.profiles" = {
        main = {
          "monitor.libcamera" = "disabled";
        };
      };
    };
  };

  powerManagement = {
    powerDownCommands = ''
      for device_wu in /sys/bus/usb/devices/*/power/wakeup; do
        echo enabled > $device_wu
      done
      ${pkgs.util-linux}/bin/rfkill block bluetooth
    '';
    powerUpCommands = ''
      ${pkgs.util-linux}/bin/rfkill unblock bluetooth
    '';
  };

  services.printing.enable = true;
  services.power-profiles-daemon.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.upower.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.libinput.enable = true;
  services.colord.enable = true;
  services.system-config-printer.enable = true;
  services.gnome.glib-networking.enable = true;
  services.gnome.gnome-settings-daemon.enable = true;

  services.avahi.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-bluetooth
    polkit_gnome
  ];

  security.pam.services.hyprlock = {};

  # Allow gsettings to work
  environment.sessionVariables.XDG_DATA_DIRS = [
    "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
  ];
}
