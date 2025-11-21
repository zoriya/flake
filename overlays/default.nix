{tmux, ...}: self: super: let
  wrapProgram = drv: bins: wrapProgramFlags:
    super.symlinkJoin {
      name = drv.name;
      paths = [drv];
      buildInputs = [super.makeWrapper];
      postBuild = super.lib.concatStrings (map (bin: ''
          wrapProgram $out/bin/${bin} \
            ${wrapProgramFlags}
        '')
        bins);
    };
  enableWayland = drv: bins:
    wrapProgram drv bins ''
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=wayland" \
      --add-flags "--disable-smooth-scrolling"'';
in {
  tmux = super.tmux.overrideAttrs {
    src = tmux;
    patches = [
      ./tmux-get_clipboard.diff
    ];
  };

  # they try to use passthrough if they detect tmux. we don't want that.
  osc = wrapProgram super.osc ["osc"] ''
    --set TMUX ""
  '';

  # Gnome-control-center can only be launched if XDG_CURRENT_DESKTOP is GNOME.
  gnome-control-center = wrapProgram super.gnome-control-center ["gnome-control-center"] "--set XDG_CURRENT_DESKTOP GNOME";

  # i can't get this to work /shrug
  # slack = super.symlinkJoin {
  #     name = super.slack.name;
  #     paths = [super.slack];
  #     buildInputs = [super.makeWrapper];
  #     postBuild = ''
  #       wrapProgram $out/bin/slack --add-flags "--disable-smooth-scrolling"
  #       substituteInPlace ${super.slack}/share/applications/slack.desktop --replace ${super.slack} $out
  #     '';
  #   };
  discord = enableWayland super.discord ["discord" "Discord"];
  vesktop = enableWayland super.vesktop ["vesktop"];
  youtube-music = enableWayland super.youtube-music ["youtube-music"];
  vscode = enableWayland super.vscode ["code"];
}
