{
  flood,
  river-src,
}: self: super: let
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
      --add-flags "--ozone-platform=wayland"'';
in {
  # Use my fork of flood to enable smart scripts.
  flood = self.pkgs.buildNpmPackage {
    pname = "flood";
    version = "4.8.2";

    src = flood;

    npmDepsHash = "sha256-md76I7W5QQvfbOmk5ODssMtJAVOj8nvaJ2PakEZ8WUA=";

    meta = with self.lib; {
      description = "A modern web UI for various torrent clients with a Node.js backend and React frontend";
      homepage = "https://flood.js.org";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [winter];
    };
  };

  river = super.river.overrideAttrs {
    src = river-src;
  };

  # Gnome-control-center can only be launched if XDG_CURRENT_DESKTOP is GNOME.
  gnome-control-center = wrapProgram super.gnome.gnome-control-center ["gnome-control-center"] "--set XDG_CURRENT_DESKTOP GNOME";

  slack = enableWayland super.slack ["slack"];
  youtube-music = enableWayland super.youtube-music ["youtube-music"];
  discord = enableWayland super.discord ["discord" "Discord"];
  vscode = enableWayland super.vscode ["code"];
}
