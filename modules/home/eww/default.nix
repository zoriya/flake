{
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
      jq
      tiramisu
      fusuma
      eww-wayland
    ];
    xdg.configFile."eww" = {
      source = ./.;
      recursive = true;
    };
    xdg.configFile."eww/_colors.scss".text = with config.colorScheme.colors; ''
    $base00: #${base00};
    $base01: #${base01};
    $base02: #${base02};
    $base03: #${base03};
    $base04: #${base04};
    $base05: #${base05};
    $base06: #${base06};
    $base07: #${base07};
    $base08: #${base08};
    $base09: #${base09};
    $base0A: #${base0A};
    $base0B: #${base0B};
    $base0C: #${base0C};
    $base0D: #${base0D};
    $base0E: #${base0E};
    $base0F: #${base0F};
    '';

    xdg.configFile."fusuma/config.yaml".source = ./fusuma.yaml;
  };
}
