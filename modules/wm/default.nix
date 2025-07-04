{pkgs, ...}: {
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

  # allow keyboard to wakeup from suspend
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="615e", ATTR{power/wakeup}="enabled"
  '';

  services.printing.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.upower.enable = true;
  services.libinput.enable = true;
  services.system-config-printer.enable = true;
  services.gnome.glib-networking.enable = true;
  services.gnome.gnome-settings-daemon.enable = true;

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

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
  };
}
