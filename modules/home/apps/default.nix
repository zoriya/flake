{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.apps;

  browser = "firefox.desktop";
  editor = "nvim.desktop";
  pdf = "org.pwmt.zathura.desktop";
  player = "mpv.desktop";
in {
  imports = [./gtk.nix];
  options.modules.apps = {enable = mkEnableOption "apps";};
  options.darkColors = lib.mkOption {
    type = with types; attrsOf str;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        (google-chrome.override {
          commandLineArgs = ["--force-dark-mode" "--enable-features=WebUIDarkMode"];
        })
        discord
        firefox
        mpv
        xdg-utils
        zathura
        libreoffice
        qbittorrent
        xdg-utils
      ];

    programs.kitty = {
      enable = true;
      settings = with config.colorScheme.colors; {
        foreground = "#${base05}";
        background = "#${base00}";
        selection_background = "#${base05}";
        selection_foreground = "#${base00}";
        url_color = "#${base04}";
        cursor = "#${base05}";
        active_border_color = "#${base03}";
        inactive_border_color = "#${base01}";
        active_tab_background = "#${base00}";
        active_tab_foreground = "#${base05}";
        inactive_tab_background = "#${base01}";
        inactive_tab_foreground = "#${base04}";
        tab_bar_background = "#${base01}";

        enable_audio_bell = false;
        cursor_blink_interval = 0;
        confirm_os_window_close = 0;
        disable_ligatures = "always";
        #placement_strategy bottom-center

        tab_bar_min_tabs = 3;
        tab_bar_style = "separator";
        tab_bar_edge = "top";
        dynamic_background_opacity = true;
      };

      extraConfig = ''
        clear_all_shortcuts yes
        kitty_mod alt
        map ctrl+shift+c copy_to_clipboard
        map ctrl+shift+v paste_from_clipboard

        map ctrl+equal change_font_size current +2.0
        map ctrl+plus change_font_size current +2.0
        map ctrl+minus change_font_size current -2.0
        map ctrl+backspace change_font_size current 0

        # map kitty_mod+r launch --type background --stdin-source=@screen_scrollback sh -c 'grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u | rofi -dmenu -p "Launch in browser" | xargs xdg-open'
        map kitty_mod+r open_url_with_hints
        map kitty_mod+t launch --type=tab --cwd=current

        map kitty_mod+e scroll_line_up
        map kitty_mod+y scroll_line_down
        map kitty_mod+h previous_tab
        map kitty_mod+l next_tab

        map kitty_mod+o scroll_to_prompt -1
        map kitty_mod+i scroll_to_prompt 1
        map kitty_mod+space show_last_command_output

      '';
    };
    programs.zsh.shellAliases = {
      ssh = "kitty +kitten ssh";
    };

    home.sessionVariables = rec {
      EDITOR = "nvim";
      VISUAL = EDITOR;
      TERMINAL = "kitty";
      BROWSER = "google-chrome-stable";
      DEFAULT_BROWSER = BROWSER;
      # For rider
      FLATPAK_ENABLE_SDK_EXT = "*";
    };
    xdg.enable = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "x-scheme-handler/magnet" = browser;
        "application/oxps" = pdf;
        "application/pdf" = pdf;
        "application/epub+zip" = pdf;
        "application/x-fictionbook+xml" = pdf;
        "text/tcl" = editor;
        "text/html" = editor;
        "text/x-makefile" = editor;
        "text/vbscript" = editor;
        "text/spreadsheet" = editor;
        "text/x-tex" = editor;
        "text/x-c++hdr" = editor;
        "text/x-pascal" = editor;
        "text/x-moc" = editor;
        "text/x-chdr" = editor;
        "text/tab-separated-values" = editor;
        "text/x-python" = editor;
        "text/x-csrc" = editor;
        "text/x-c++src" = editor;
        "text/x-java" = editor;
        "text/plain" = editor;
        "text/csv" = editor;
        "video/x-flic" = player;
        "video/mpeg" = player;
        "video/x-ms-wmv" = player;
        "video/vnd.rn-realvideo" = player;
        "video/x-theora+ogg" = player;
        "video/dv" = player;
        "video/webm" = player;
        "video/ogg" = player;
        "video/quicktime" = player;
        "video/x-flv" = player;
        "video/x-ogm+ogg" = player;
        "video/3gpp2" = player;
        "video/mp2t" = player;
        "video/x-msvideo" = player;
        "video/3gpp" = player;
        "video/x-matroska" = player;
        "video/vnd.mpegurl" = player;
        "video/mp4" = player;
        "audio/aac" = player;
        "audio/ac3" = player;
        "audio/x-wavpack" = player;
        "audio/webm" = player;
        "audio/x-ms-wma" = player;
        "audio/flac" = player;
        "audio/x-scpls" = player;
        "audio/mpeg" = player;
        "audio/x-mpegurl" = player;
        "audio/x-ms-asx" = player;
        "audio/vnd.rn-realaudio" = player;
        "audio/x-wav" = player;
        "audio/vnd.dts" = player;
        "audio/x-adpcm" = player;
        "audio/x-vorbis+ogg" = player;
        "audio/mp4" = player;
        "audio/x-tta" = player;
        "audio/x-musepack" = player;
        "audio/AMR" = player;
        "audio/x-matroska" = player;
        "audio/x-ape" = player;
        "audio/x-aiff" = player;
        "audio/vnd.dts.hd" = player;
        "audio/ogg" = player;
        "audio/mp2" = player;
      };
    };
    xdg.userDirs = {
      enable = true;
      download = "${config.home.homeDirectory}/downloads";
      desktop = config.home.homeDirectory;

      documents = "${config.home.homeDirectory}/stuff";
      music = "${config.home.homeDirectory}/stuff";
      templates = "${config.home.homeDirectory}/stuff";
      videos = "${config.home.homeDirectory}/stuff";
      pictures = "${config.home.homeDirectory}/stuff";
      publicShare = "${config.home.homeDirectory}/stuff";
    };

    xdg.configFile."nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    '';
  };
}
