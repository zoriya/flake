{
  flood,
  river-src,
  ...
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
  flood = super.flood.overrideAttrs rec {
    src = flood;
    npmDeps = pnpmDeps;
    pnpmDeps = super.pnpm_9.fetchDeps {
      pname = "flood";
      version = "4.9.4-dirty";
      src = flood;
      hash = "sha256-E2VxRcOMLvvCQb9gCAGcBTsly571zh/HWM6Q1Zd2eVw=";
    };
  };

  river = super.river.overrideAttrs {
    src = river-src;
  };

  # Gnome-control-center can only be launched if XDG_CURRENT_DESKTOP is GNOME.
  gnome-control-center = wrapProgram super.gnome-control-center ["gnome-control-center"] "--set XDG_CURRENT_DESKTOP GNOME";

  slack = enableWayland super.slack ["slack"];
  discord = enableWayland super.discord ["discord" "Discord"];
  vesktop = enableWayland super.vesktop ["vesktop"];
  youtube-music = enableWayland super.youtube-music ["youtube-music"];
  vscode = enableWayland super.vscode ["code"];
}
