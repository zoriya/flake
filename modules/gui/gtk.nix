{pkgs, ...}: rec {
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

  qt.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };
}
