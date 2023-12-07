{pkgs, ags, ...}: {
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

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    dwl
    polkit_gnome
    ags.packages.x86_64-linux.default
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
  ];
  hardware.steam-hardware.enable = true;
  hardware.opengl.driSupport32Bit = true;
  services.flatpak.enable = true;

  # Those two lines prevent a crash with gdm autologin.
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  services.printing.enable = true;
  security.rtkit.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;

  security.polkit.enable = true;

  # needed for GNOME services outside of GNOME Desktop
  services = {
    dbus.packages = [pkgs.gcr];
    udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  };

  programs.dconf.enable = true;
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
  };

  services.upower.enable = true;
  services.gvfs.enable = true;

  # i18n.inputMethod.enabled = "ibus";
  # i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [mozc];
}
