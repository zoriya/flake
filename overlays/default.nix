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
  };

  # it doesn't start without this, no clue why.
  freecad = wrapProgram super.freecad ["freecad" "FreeCAD" "freecadcmd" "FreeCADCmd"] ''
    --set QT_QPA_PLATFORM 'wayland;xcb' \
    --set QT_QPA_PLATFORMTHEME qt5ct
  '';

  # Gnome-control-center can only be launched if XDG_CURRENT_DESKTOP is GNOME.
  gnome-control-center = wrapProgram super.gnome-control-center ["gnome-control-center"] "--set XDG_CURRENT_DESKTOP GNOME";

  slack = enableWayland super.slack ["slack"];
  discord = enableWayland super.discord ["discord" "Discord"];
  vesktop = enableWayland super.vesktop ["vesktop"];
  youtube-music = enableWayland super.youtube-music ["youtube-music"];
  vscode = enableWayland super.vscode ["code"];
}
