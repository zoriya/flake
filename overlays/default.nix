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
  flood = self.stdenv.mkDerivation (finalAttrs: {
    pname = "flood";
    version = "4.8.4-dirty";

    src = flood;

    nativeBuildInputs = with self.pkgs; [
      nodejs
      pnpm.configHook
      super.makeWrapper
    ];

    pnpmDeps = self.pkgs.pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      hash = "sha256-as/ZVgR+yf9tkz+HG1U66oKGvpTGMW23dQ9M7QHnV4U=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/{lib,bin}
      cp -r {dist,node_modules} $out/lib
      makeWrapper ${self.pkgs.nodejs}/bin/node $out/bin/flood --add-flags $out/lib/dist/index.js
      runHook postInstall
    '';

    dontStrip = true;

    meta = with self.lib; {
      description = "A modern web UI for various torrent clients with a Node.js backend and React frontend";
      homepage = "https://flood.js.org";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [winter];
    };
  });

  river = super.river.overrideAttrs {
    src = river-src;
  };

  wbg = super.wbg.overrideAttrs {
    env.NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=maybe-uninitialized"
    ];
  };

  # Gnome-control-center can only be launched if XDG_CURRENT_DESKTOP is GNOME.
  gnome-control-center = wrapProgram super.gnome-control-center ["gnome-control-center"] "--set XDG_CURRENT_DESKTOP GNOME";

  slack = enableWayland super.slack ["slack"];
  discord = enableWayland super.discord ["discord" "Discord"];
  vesktop = enableWayland super.vesktop ["vesktop"];
  youtube-music = enableWayland super.youtube-music ["youtube-music"];
  vscode = enableWayland super.vscode ["code"];
}
