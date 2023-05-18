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
      # Waiting for https://github.com/bdaase/noannoyance/pull/29
      disable-extension-version-validation = true;
      enabled-extensions = [
        "fairy@zoriya.dev"
        # "noannoyance@daase.net"
        # Waiting for https://github.com/aunetx/blur-my-shell/issues/388
        # "blur-my-shell@aunetx"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
        "default-workspace@mateusrodcosta.com"
        "pano@elhan.io"
        "just-perfection-desktop@just-perfection"
        # "color-picker@tuberry"
        "unite@hardpixel.eu"
        "WallpaperSwitcher@Rishu"
        # Waiting for https://github.com/yilozt/rounded-window-corners/issues/121
        # "rounded-window-corners@yilozt.shell-extension.zip"
        # Disable while not configured
        # "widgets@aylur"
      ];
      welcome-dialog-last-shown-version = 999999;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 900;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-battery-timeout = 1800;
      sleep-inactive-ac-timeout = 1800;
    };

    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
    };

    "org/gnome/mutter" = {
      focus-change-on-pointer-rest = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      auto-raise = true;
      num-workspaces = 9;
      resize-with-right-button = true;
      focus-mode = "sloppy";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      disable-overview-on-startup = true;
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
      workspaces-only-on-primary = true;
    };
    "org/gnome/desktop/interface" = {
      scaling-factor = 1.5;
      # Dark mode by default
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
      show-battery-percentage = true;
      cursor-blink = false;
      monospace-font-name = "JetBrainsMono Nerd Font 10";
      locate-pointer = true;
    };
    "org/gnome/desktop/input-sources" = {
      mru-sources = [(mkTuple ["xkb" "us"]) (mkTuple ["ibus" "mozc-jp"])];
      sources = [(mkTuple ["xkb" "us"]) (mkTuple ["ibus" "mozc-jp"])];
      xkb-options = ["terminate:ctrl_alt_bksp" "caps:swapescape"];
    };

    "org/gnome/desktop/wm/keybindings" = {
      minimize = [];
      activate-window-menu = [];
      close = ["<Super>c"];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = ["<Super><Shift>l"];
    };

    "org/gnome/shell/keybindings" = {
      toggle-message-tray = [];
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];
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

    "org/gnome/shell/extensions/WallpaperSwitcher" = {
      wallpaper-path = "/home/zoriya/wallpapers";
      switching-mode = 1;
      frequency = 3000;
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = "file:///home/zoriya/wallpapers/default";
    };

    "org/gnome/desktop/background" = {
      # Setting default images for before the wallpaper switcher runs.
      picture-uri = "file:///home/zoriya/wallpapers/default";
      picture-uri-dark = "file:///home/zoriya/wallpapers/default";
    };

    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = ["discord.desktop:3" "youtube-music.desktop:3"];
    };

    "org/gnome/shell/extensions/default-workspace" = {
      default-workspace-number = 4;
    };

    # Disable globally all the option, leave only the options to disable client decorations.
    "org/gnome/shell/extensions/unite" = {
      extend-left-box = false;
      autofocus-windows = false;
      show-legacy-tray = false;
      show-desktop-name = false;
      enable-titlebar-actions = false;
      restrict-to-primary-screen = false;
      hide-activities-button = "always";
      hide-window-titlebars = "always";
      show-window-title = "never";
      show-window-buttons = "never";
      notifications-position = "center";
      hide-dropdown-arrows = false;
      hide-app-menu-icon = true;
      reduce-panel-spacing = false;
      desktop-name-text = "";
    };

    "org/gnome/shell/extensions/pano" = {
      history-length = 500;
      global-shortcut = ["<Super>v"];
      incognito-shortcut = ["<Shift><Control><Alt><Super>v"];
      paste-on-select = true;
      send-notification-on-copy = false;
      play-audio-on-copy = false;
      keep-search-entry = false;
      show-indicator = false;
    };

    "org/gnome/shell/extensions/fairy" = { 
      tag-names = ["一" "二" "三" " 四" "五" "六" "七" "八" "九"];
    };

    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = false;
      background-menu = false;
      clock-menu-position = 1;
      clock-menu-position-offset = 10;
      dash = false;
      workspace-switcher-size = 10;
      startup-status = 0;
      theme = false;
      window-demands-attention-focus = true;
      window-preview-caption = false;
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    blur-my-shell
    just-perfection
    rounded-window-corners
    aylurs-widgets
    wallpaper-switcher
    noannoyance-2
    default-workspace
    wallpaper
    pano
    color-picker
    unite
  ];

  xdg.configFile."autostart/discord.desktop".source = "${pkgs.discord}/share/applications/discord.desktop";
  xdg.configFile."autostart/youtube-music.desktop".source = "${pkgs.youtube-music}/share/applications/youtube-music.desktop";
}
