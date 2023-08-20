{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.fonts;
in {
  imports = [./flatpak_fonts.nix];
  options.fonts = {enable = lib.mkEnableOption "fonts";};
  config = lib.mkIf cfg.enable {
    console = {
      font = "ter-i32b";
      packages = with pkgs; [terminus_font];
      earlySetup = true;
    };
    fonts = {
      packages = with pkgs; [
        roboto
        dejavu_fonts
        # Some japanese fonts
        ipafont
        kochi-substitute
        (nerdfonts.override {fonts = ["JetBrainsMono"];})
      ];

      fontconfig = {
        defaultFonts = {
          monospace = [
            "JetBrainsMono NL Nerd Font"
            "IPAGothic"
          ];
          sansSerif = [
            "DejaVu Sans"
            "IPAPGothic"
          ];
          serif = [
            "DejaVu Serif"
            "IPAPMincho"
          ];
        };
      };
    };
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
