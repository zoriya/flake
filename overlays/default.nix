{dwl-source}: self: super: let
  enableWayland = drv: bins:
    super.symlinkJoin {
      name = drv.name;
      paths = [drv];
      buildInputs = [super.makeWrapper];
      postBuild = super.lib.concatStrings (map (bin: ''
          wrapProgram $out/bin/${bin} \
            --add-flags "--enable-features=UseOzonePlatform" \
            --add-flags "--ozone-platform=wayland"
        '')
        bins);
    };
in {
  dwl =
    (super.dwl.override
      {conf = ../modules/dwl/config.h;})
    .overrideAttrs (oldAttrs: {
      src = dwl-source;
      enableXWayland = true;
      passthru.providedSessions = [ "dwl" ];
      patches = [
        ../dwl_patches/autostart.patch
        ../dwl_patches/deck.patch
        ../dwl_patches/point.patch
        ../dwl_patches/output-power-managment.patch
        ../dwl_patches/keyboard-shortcut-inhibit.patch
        ../dwl_patches/cursor_wrap.patch
        ../dwl_patches/vanitygaps.patch
        ../dwl_patches/vanity_deck.patch
        ../dwl_patches/smartborders.patch
        ../dwl_patches/desktop.patch
        ../dwl_patches/togglelayout.patch
        ../dwl_patches/toggletag.patch
        ../dwl_patches/singletagset.patch
      ];
    });

  tuxedo-keyboard = super.callPackage ./tuxedo-keyboard {};
  slack = enableWayland super.slack ["slack"];
  discord = enableWayland super.discord ["discord" "Discord"];
  youtube-music = enableWayland super.youtube-music ["youtube-music"];
  vscode = enableWayland super.vscode ["code"];
}
