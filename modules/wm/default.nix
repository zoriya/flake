{pkgs, ...}: {
  networking.networkmanager.enable = true;
  hardware.pulseaudio.enable = false;
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

  programs.dconf.enable = true;
  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    gnome.gnome-bluetooth
    polkit_gnome
  ];

  security.pam.services.hyprlock = {};
}
