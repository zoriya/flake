{
  pkgs,
  user,
  ...
}: {
  imports = [
    ../../modules/wm
    ../../modules/gui
  ];

  programs.niri.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd zsh";
        user = "greeter";
      };
      initial_session = {
        command = ./niri-session.sh; # "${pkgs.niri}/bin/niri-session";
        user = user;
      };
    };
  };
}
