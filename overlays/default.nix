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
  enableWayland = drv: bins:
    wrapProgram drv bins ''
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=wayland"'';
in rec {
  # Override source with latest version.
  dwl =
    (super.dwl.override
      {conf = ../modules/dwl/config.h;})
    .overrideAttrs (oldAttrs: {
      version = "0.5";
      src = dwl-source;
      enableXWayland = true;
      passthru.providedSessions = ["dwl"];
      buildInputs = oldAttrs.buildInputs ++ [wlroots];
    });

  wlroots = (super.callPackage ./wlroots.nix {}).wlroots;

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
  discord = enableWayland super.discord ["discord" "Discord"];
  vscode = enableWayland super.vscode ["code"];
}
