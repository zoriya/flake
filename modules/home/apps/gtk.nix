{ config, pkgs, ... }:
  rec {
    gtk = {
      enable = true;
      theme = {
        name = pkgs.adw-gtk3.pname;
        package = pkgs.adw-gtk3;
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
