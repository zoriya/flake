{
  ghostty,
  pkgs,
  lib,
  ...
}: {
  xdg.configFile."ghostty/config".source = ./ghostty.config;

  home.packages = lib.optionals pkgs.stdenv.isLinux [
    ghostty.packages.${pkgs.system}.default
  ];
}
