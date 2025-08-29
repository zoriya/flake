{
  config,
  lib,
  pkgs,
  zen-browser,
  ...
}: let
  # When editing this, don't forget to edit home.sessionVariables.
  browser = "zen.desktop";
  editor = "nvim.desktop";
  pdf = "org.pwmt.zathura.desktop";
  player = "mpv.desktop";
in {
  imports = [
    ./ghostty.nix
    ./kitty.nix
    ./gtk.nix
  ];

  home.packages = with pkgs;
    [
      firefox
      zen-browser.packages.${pkgs.system}.default
      vesktop
      mpv
      freecad
      kicad
      xdg-utils
      zathura
      libreoffice
      qbittorrent
      youtube-music
      wl-clipboard
      wlr-randr
      alsa-utils
      playerctl
      postman
    ]
    ++ lib.optionals pkgs.stdenv.isx86_64 [google-chrome];

  home.sessionVariables = rec {
    # TODO: add an `uwsm app run --` or something here (for example clicking on a link on discord opens the browser on discord's slice instead of the browser's slice.
    TERMINAL = "kitty";
    BROWSER = "zen";
    DEFAULT_BROWSER = BROWSER;
  };
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
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
    userDirs = {
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
  home.file.".face".source = ../../face.png;

  xdg.configFile."autostart/vesktop.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Vesktop
    Comment=Vesktop autostart script
    Exec="${pkgs.vesktop}/bin/vesktop"
    StartupNotify=false
    Terminal=false
  '';
}
