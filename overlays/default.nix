self: super: 
  let
    enableWayland = drv: bins: 
      super.symlinkJoin {
        name = drv.name;
        paths = [ drv ];
        buildInputs = [ super.makeWrapper ];
        postBuild = super.lib.concatStrings (map (bin: ''
          wrapProgram $out/bin/${bin} \
            --add-flags "--enable-features=UseOzonePlatform" \
            --add-flags "--ozone-platform=wayland"
        '') bins);
      };
  in {
    tuxedo-keyboard = super.callPackage ./tuxedo-keyboard {};
    slack = enableWayland super.slack ["slack"];
    discord = enableWayland super.discord ["discord" "Discord"];
    youtube-music = enableWayland super.youtube-music ["youtube-music"];
    vscode = enableWayland super.vscode ["code"];
  }
