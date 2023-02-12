{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.fonts;
in {
  options.fonts = {enable = lib.mkEnableOption "fonts";};
  config = lib.mkIf cfg.enable {
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "ter-i32b";
      packages = with pkgs; [terminus_font];
      earlySetup = true;
    };
    fonts = {
      fonts = with pkgs; [
        roboto
        (nerdfonts.override {fonts = ["JetBrainsMono"];})
      ];

      fontconfig = {
        hinting.autohint = true;
        defaultFonts = {
          monospace = ["JetBrainsMono"];
        };
      };
    };
  };
}
