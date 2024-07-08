{pkgs, ...}: let
  wallpaper = pkgs.writeShellScriptBin "wallpaper" ''
    WALLPAPERS=~/wallpapers/

    WP=$(find $WALLPAPERS -type f | shuf -n 1)
    ln -fs "$WP" ~/.cache/current-wallpaper

    ${pkgs.wbg}/bin/wbg "$WP" > /dev/null 2> /dev/null & disown
    echo "$WP"
  '';
in {
  imports = [
    ./rofi
    ./ags
  ];
  home.packages = [
    wallpaper
  ];
}
