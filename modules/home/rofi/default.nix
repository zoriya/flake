{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.rofi;
in {
  options.modules.rofi = {enable = lib.mkEnableOption "rofi";};
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [rofi-wayland];
    home.file.".config/rofi" = {
      source = ./.;
      recursive = true;
    };
  };
}
