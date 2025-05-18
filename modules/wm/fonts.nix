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

  # Create an FHS mount to support flatpak host icons/fonts
  # system.fsPackages = [pkgs.bindfs];
  # fileSystems = let
  #   mkRoSymBind = path: {
  #     device = path;
  #     fsType = "fuse.bindfs";
  #     options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
  #   };
  #   aggregatedFonts = pkgs.buildEnv {
  #     name = "system-fonts";
  #     paths = config.fonts.packages;
  #     pathsToLink = ["/share/fonts"];
  #   };
  # in {
  #   # icons don't work, don't know why, don't care
  #   # "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
  #   "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
  # };
}
