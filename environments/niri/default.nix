{
  pkgs,
  user,
  noctalia-greeter,
  ...
}: {
  imports = [
    ../../modules/wm
    ../../modules/gui
    noctalia-greeter.nixosModules.default
  ];

  programs.niri.enable = true;
  services.graphical-desktop.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.power-profiles-daemon.enable = true;

  nix.settings = {
    extra-substituters = ["https://noctalia.cachix.org"];
    extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
  };

  programs.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "niri";
      user.default = user;
      keyboard.options = "caps:escape_shifted_capslock";
      appearance = {
        scheme = "Catppuccin";
        wallpaper.path = ../../wallpapers/blue-period.jpg;
        wallpaper.fill_mode = "crop";
      };
    };
  };

  systemd.services.avatar = {
    description = "Set ${user}'s avatar";
    wantedBy = ["graphical.target"];
    before = ["greetd.service"];
    after = ["accounts-daemon.service"];
    serviceConfig = {
      Type = "oneshot";
      User = user;
      ExecStart = pkgs.writeShellScript "set-avatar" ''
        ${pkgs.glib}/bin/gdbus call --system --dest org.freedesktop.Accounts \
          --object-path "/org/freedesktop/Accounts/User$(id -u)" \
          --method org.freedesktop.Accounts.User.SetIconFile ${../../face.png}
      '';
    };
  };
}
