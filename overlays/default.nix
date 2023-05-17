self: super: 
  let
    enableWayland = drv: bins: drv.overrideAttrs (
      old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ self.makeWrapper ];
        postFixup = map (bin: (old.postFixup or "") + ''
          wrapProgram $out/bin/${bin} \
            --add-flags "--enable-features=UseOzonePlatform" \
            --add-flags "--ozone-platform=wayland"
        '') bins;
      }
    );
  in {
    tuxedo-keyboard = super.callPackage ./tuxedo-keyboard {};
    slack = enableWayland super.slack ["slack"];
    discord = enableWayland super.discord ["discord" "Discord"];
    youtube-music = enableWayland super.youtube-music ["youtube-music"];
    vscode = enableWayland super.vscode ["code"];
  }
