{ config, pkgs, nix-colors, ... }:
let
  inherit (nix-colors.lib-contrib { inherit pkgs; }) gtkThemeFromScheme;
in
  rec {
    gtk = {
      enable = true;
      theme = {
        name = "${config.colorscheme.slug}";
        package = gtkThemeFromScheme { scheme = config.colorscheme; };
      };
    };

    services.xsettingsd = {
      enable = true;
      settings = {
        "Net/ThemeName" = "${gtk.theme.name}";
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
    };
  }
