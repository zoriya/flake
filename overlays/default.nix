{
  dwl-source,
  flood,
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
  enableWayland = drv: bins: wrapProgram drv bins ''
    --add-flags "--enable-features=UseOzonePlatform" \
    --add-flags "--ozone-platform=wayland"'';
in {
  # Patch dwl.
  dwl =
    (super.dwl.override
      {conf = ../modules/dwl/config.h;})
    .overrideAttrs (oldAttrs: {
      src = dwl-source;
      enableXWayland = true;
      passthru.providedSessions = ["dwl"];
      patches = [
        ../dwl_patches/autostart.patch
        ../dwl_patches/deck.patch
        ../dwl_patches/output-power-managment.patch
        ../dwl_patches/keyboard-shortcut-inhibit.patch
        ../dwl_patches/cursor_warp.patch
        ../dwl_patches/vanitygaps.patch
        ../dwl_patches/vanity_deck.patch
        ../dwl_patches/smartborders.patch
        ../dwl_patches/desktop.patch
        ../dwl_patches/togglelayout.patch
        ../dwl_patches/toggletag.patch
        ../dwl_patches/singletagset.patch
        ../dwl_patches/montagset.patch
        ../dwl_patches/movestack.patch
        ../dwl_patches/gdk_monitors_status.patch
        ../dwl_patches/rotatetags.patch
        ../dwl_patches/naturalscrolltrackpad.patch
        ../dwl_patches/pointer-gesture.patch
        ../dwl_patches/sway-pointer-contraints.patch
        ../dwl_patches/retore-tiling.patch
      ];
    });

  # Use my fork of flood to enable smart scripts.
  flood = self.pkgs.buildNpmPackage {
    pname = "flood";
    version = "4.7.0";

    src = flood;

    npmDepsHash = "sha256-XmDnvq+ni5TOf3UQFc4JvGI3LiGpjbrLAocRvrW8qgk=";

    # The prepack script runs the build script, which we'd rather do in the build phase.
    npmPackFlags = ["--ignore-scripts"];

    NODE_OPTIONS = "--openssl-legacy-provider";

    meta = with self.lib; {
      description = "A modern web UI for various torrent clients with a Node.js backend and React frontend";
      homepage = "https://flood.js.org";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [winter];
    };
  };

  # Gnome-control-center can only be launched if XDG_CURRENT_DESKTOP is GNOME.
  gnome-control-center = wrapProgram super.gnome.gnome-control-center ["gnome-control-center"] "--set XDG_CURRENT_DESKTOP GNOME";

  slack = enableWayland super.slack ["slack"];
  youtube-music = enableWayland super.slack ["youtube-music"];
  discord = enableWayland super.discord ["discord" "Discord"];
  vscode = enableWayland super.vscode ["code"];
}
