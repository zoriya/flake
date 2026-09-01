{
  pkgs,
  # config,
  ...
}: {
  console = {
    font = "ter-i32b";
    packages = with pkgs; [terminus_font];
    earlySetup = true;
  };

  fonts = {
    packages = with pkgs; [
      roboto
      dejavu_fonts
      nerd-fonts.jetbrains-mono
      # Some japanese fonts
      ipafont
      kochi-substitute
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

      # HIDPI settings
      subpixel.lcdfilter = "none";
      hinting.enable = false;
    };
  };
  i18n.defaultLocale = "en_US.UTF-8";

  environment.variables = {
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
  };
}
