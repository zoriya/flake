{
  pkgs,
  ags,
  ...
}: let
  dwl-patched = pkgs.dwl.overrideAttrs (old: {
    patches = [
    ../../dwl_patches/deck.patch
    # ../../dwl_patches/output-power-managment.patch
    # ../../dwl_patches/keyboard-shortcut-inhibit.patch
    ../../dwl_patches/cursor_warp.patch
    ../../dwl_patches/vanitygaps.patch
    ../../dwl_patches/vanity_deck.patch
    ../../dwl_patches/smartborders.patch
    ../../dwl_patches/togglelayout.patch
    ../../dwl_patches/toggletag.patch
    # ../../dwl_patches/singletagset.patch
    ../../dwl_patches/montagset.patch
    ../../dwl_patches/movestack.patch
    ../../dwl_patches/gdk_monitors_status.patch
    ../../dwl_patches/rotatetags.patch
    ../../dwl_patches/naturalscrolltrackpad.patch
    ../../dwl_patches/pointer-gesture.patch
    ../../dwl_patches/sway-pointer-contraints.patch
    ../../dwl_patches/retore-tiling.patch
    ];
  });

  dwlp = pkgs.writeShellScriptBin "dwl" ''
  ${dwl-patched}/bin/dwl -s ags
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots

  # Stop any services that are running, so that they receive the new env var when they restart.
  systemctl --user stop pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
  systemctl --user start wireplumber

  fusuma -c ~/.config/fusuma/config.yaml &
  ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
  ydotoold &
  shikane &
  wl-paste --watch cliphist store &

  wallpaper
  discord &
  youtube-music &
  '';
in {
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
    dwlp
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
