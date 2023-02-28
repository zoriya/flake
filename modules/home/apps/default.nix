{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.apps;

  browser = "google-chrome.desktop";
  editor = "nvim.desktop";
  pdf = "org.pwmt.zathura.desktop";
  player = "mpv.desktop";
  lock = pkgs.writeShellScriptBin "lock" ''
    swaylock --image $(find ${config.home.homeDirectory}/wallpapers/ -type f | shuf -n 1)
  '';
in {
  options.modules.apps = {enable = mkEnableOption "apps";};

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        google-chrome
        firefox
        mpv
        xdg-utils
        discord
        swaylock
        swayidle
      ]
      ++ [lock];

    programs.kitty = {
      enable = true;
      extraConfig = ''
        enable_audio_bell no
        confirm_os_window_close 0
        disable_ligatures always

        clear_all_shortcuts yes
        kitty_mod alt
        map ctrl+shift+c copy_to_clipboard
        map ctrl+shift+v paste_from_clipboard
        

        # map kitty_mod+r launch --type background --stdin-source=@screen_scrollback sh -c 'grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u | rofi -dmenu -p "Launch in browser" | xargs xdg-open'
        map kitty_mod+r open_url_with_hints
        map kitty_mod+n launch --type=tab --cwd=current

        map kitty_mod+k scroll_line_up
        map kitty_mod+j scroll_line_down
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

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "kitty";
      BROWSER = "google-chrome-stable";
    };
    xdg.enable = true;
    xdg.mimeApps = {
      enable = false;
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
  };
}
