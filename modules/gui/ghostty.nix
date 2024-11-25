{
  ghostty,
  system,
  pkgs,
  lib,
  ...
}: {
  xdg.configFile."ghostty/config".source = ./ghostty.config;

  home.packages = lib.optionals pkgs.stdenv.isLinux [
    ghostty.packages.${system}.default
  ];
}
