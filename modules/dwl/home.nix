{
  pkgs,
  lib,
  config,
  user,
  ...
}: {
  home.packages = with pkgs; [
    dwl
    alsa-utils
  ];
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };
}
