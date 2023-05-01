{
  lib,
  config,
  pkgs,
  user,
  ...
}: let
  cfg = config.wayland;
in {
  options.wayland = {enable = lib.mkEnableOption "wayland";};
  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    security.rtkit.enable = true;
    security.polkit.enable = true;

    # Pipewire just refuses to have a decent mic so I will use pulseaudio for now
    hardware.pulseaudio = {
      enable = true;
      support32Bit = true;
    };
    # services.pipewire = {
    #   enable = true;
    #   alsa.enable = true;
    #   alsa.support32Bit = true;
    #   jack.enable = true;
    #   pulse.enable = true;
    #   socketActivation = true;
    # };
    hardware.bluetooth.enable = true;

    # Autostart hyprland and display lockscreen as greeter
    # See https://github.com/NixOS/nixpkgs/issues/140304 for why this looks weird
    services.getty = {
      loginProgram = "${pkgs.bash}/bin/sh";
      loginOptions = toString (pkgs.writeText "login-program.sh" ''
        if [[ "$(tty)" == '/dev/tty1' ]]; then
          ${pkgs.shadow}/bin/login -f ${user};
        else
          ${pkgs.shadow}/bin/login;
        fi
      '');
      extraArgs = ["--skip-login"];
    };
    security.pam.services.swaylock = {};
    environment.systemPackages = with pkgs; [
      swaylock
    ];

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        wants = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    security.sudo.extraConfig = ''
      Defaults  lecture="never"
    '';

    boot = {
      kernelParams = ["quiet" "splash"];
      consoleLogLevel = 0;
      initrd.verbose = false;
      plymouth = {
        enable = true;
        themePackages = [pkgs.adi1090x-plymouth];
        theme = "colorful_loop";
      };
    };
  };
}
