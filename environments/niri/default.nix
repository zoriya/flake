{
  pkgs,
  user,
  ...
}: {
  imports = [
    ../../modules/wm
    ../../modules/gui
  ];

  services.graphical-desktop.enable = true;
  services.gnome.gnome-keyring.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd zsh";
        user = "greeter";
      };
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = user;
      };
    };
  };
}
