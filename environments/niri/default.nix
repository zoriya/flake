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
  services.power-profiles-daemon.enable = true;

  nix.settings = {
    extra-substituters = ["https://noctalia.cachix.org"];
    extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
  };

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
