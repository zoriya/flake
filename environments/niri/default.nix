{
  pkgs,
  user,
  inputs,
  ...
}: {
  imports = [
    ../../modules/wm
    ../../modules/gui
  ];

  programs.niri.enable = true;

  services.power-profiles-daemon.enable = true;

  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd zsh";
        user = "greeter";
      };
      initial_session = {
        command = ./niri-session.sh;
        user = user;
      };
    };
  };
}
