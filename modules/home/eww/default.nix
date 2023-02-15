{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.eww;
in {
  options.modules.eww = {enable = mkEnableOption "eww";};

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pamixer
      brightnessctl
      material-icons
      blueberry
      bluez
      gnunet
      jaq
      light
      networkmanagerapplet
      pavucontrol
      playerctl
      procps
      socat
      udev
      upower
      util-linux
      wget
      wireplumber
      wlogout
      bc
      tiramisu
    ];
    programs.eww = {
      enable = true;
      package = pkgs.eww-wayland;
      configDir = ./.;
    };
  };
}
