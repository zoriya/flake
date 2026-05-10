{pkgs, ...}: {
  imports = [
    ../../modules/gui/home.nix
    ../../modules/wm/home.nix
  ];
  services.gnome-keyring.enable = true;

  home.packages = with pkgs; [
    pamixer
    brightnessctl
    playerctl
    hyprpicker
    wtype

    gnome-control-center
    gnome-weather
    wdisplays
  ];

  wayland.windowManager.niri = {
    enable = true;
    systemd.enable = true;
    extraConfig = builtins.readFile ./niri.kdl;
  };

  xdg.configFile."systemd/user/niri.service.d/unset-shlvl.conf".text = ''
    [Service]
    UnsetEnvironment=SHLVL
  '';

  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        output.criteria = "eDP-1";
        output.scale = 1.6;
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Dell Inc. DELL S2722QC 2HHZH24";
            # position = "1500,0";
            position = "0,900";
            scale = 1.7;
          }
          {
            criteria = "*";
            position = "0,0";
            scale = 1.4;
          }
        ];
      }
    ];
  };
}
