{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "agreety --cmd /bin/sh";
        user = "greeter";
      };
      initial_session = {
        # TODO: Start river in locked mode or exit if locker crashes.
        # zsh -c is to give river access to profile variables
        command = "zsh -c river";
        user = "zoriya";
      };
    };
  };

  networking.networkmanager.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
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
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-bluetooth
    polkit_gnome
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
  ];
  hardware.steam-hardware.enable = true;
  services.flatpak.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}