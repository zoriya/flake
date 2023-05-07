{
  config,
  lib,
  pkgs,
  ...
}: {
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "forge@jmmaranan.com"
        "blur-my-shell@aunetx"
        "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
        # "just-perfection-desktop@just-perfection"
        "rounded-window-corners@yilozt.shell-extension.zip"
        # Disable while not configured
        # "widgets@aylur"
      ];
      welcome-dialog-last-shown-version = 999999;
    };
    # "org/gnome/shell/extensions/just-perfection" = {
    #   activities-button = false;
    #   startup-status = 0;
    #   dash = false;
    # };
    "org/gnome/shell/world-clocks" = {
      # locations = "[<(uint32 2, <('Nantes', 'LFRS', true, [(0.82321363634175626, -0.027925268031909273)], [(0.82408630096775348, -0.027052603405912107)])>)>]";
    };
    "org/gnome/shell/weather" = {
      automatic-location = true;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
    };
    "org/gnome/mutter" = {
      experimental-features = ["scale-monitor-framebuffer"];
    };
    "org/gnome/desktop/interface" = {
      scaling-factor = 1.5;
      # Dark mode by default
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = ["terminate:ctrl_alt_bksp" "caps:swapescape"];
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    forge
    blur-my-shell
    # just-perfection
    rounded-window-corners
    aylurs-widgets
  ];
}
