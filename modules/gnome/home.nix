{
  config,
  lib,
  pkgs,
  ...
}: let
  wallpaper = pkgs.writeShellScriptBin "wallpaper" (builtins.readFile ./wallpaper.sh);
in {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "forge@jmmaranan.com"
        # Waiting for https://github.com/aunetx/blur-my-shell/issues/388
        # "blur-my-shell@aunetx"
        "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
        "rounded-window-corners@yilozt.shell-extension.zip"
        # Disable while not configured
        # "widgets@aylur"
        # "just-perfection-desktop@just-perfection"
      ];
      welcome-dialog-last-shown-version = 999999;
    };

    "org/gnome/desktop/wm/preferences" = {
      auto-raise = true;
      num-workspaces=9;
    };
    # "org/gnome/shell/extensions/just-perfection" = {
    #   activities-button = false;
    #   startup-status = 0;
    #   dash = false;
    # };
    # "org/gnome/shell/world-clocks" = {
    #   locations = "[<(uint32 2, <('Nantes', 'LFRS', true, [(0.82321363634175626, -0.027925268031909273)], [(0.82408630096775348, -0.027052603405912107)])>)>]";
    # };
    # "org/gnome/Weather" = {
    #   locations = "[<(uint32 2, <('Tokyo', 'RJTI', true, [(0.62191898430954862, 2.4408429589140699)], [(0.62282074357417661, 2.4391218722853854)])>)>]";
    # };
    "org/gnome/shell/weather" = {
      automatic-location = true;
      # locations = "[<(uint32 2, <('Tokyo', 'RJTI', true, [(0.62191898430954862, 2.4408429589140699)], [(0.62282074357417661, 2.4391218722853854)])>)>]";
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
    };
    "org/gnome/mutter" = {
      experimental-features = ["scale-monitor-framebuffer"];
      overlay-key = "";
      workspaces-only-on-primary=true;
    };
    "org/gnome/desktop/interface" = {
      scaling-factor = 1.5;
      # Dark mode by default
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
      show-battery-percentage = true;
    };
    # "org/gnome/desktop/background" = {
    #   picture-uri = "file:///home/zoriya/.cache/current-wallpaper";
    #   picture-uri-dark = "file:///home/zoriya/.cache/current-wallpaper";
    # };
    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "ibus" "mozc-jp" ]) ];
      sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "ibus" "mozc-jp" ]) ];
      xkb-options = ["terminate:ctrl_alt_bksp" "caps:swapescape"];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>e";
      command = "kitty";
      name = "Open Terminal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>r";
      command = "firefox";
      name = "Firefox";
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    forge
    blur-my-shell
    # just-perfection
    rounded-window-corners
    aylurs-widgets
    wallpaper
  ];

  # xdg.configFile."autostart/wallpaper.desktop".text = ''
  #   [Desktop Entry]
  #   Type=Application
  #   Name=Wallpapers
  #   Exec=wp
  #   OnlyShowIn=GNOME;
  # '';
  xdg.configFile."autostart/discord.desktop".text = pkgs.discord.desktopItem.text;
}
