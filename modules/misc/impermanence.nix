{impermanence, ...}: {
  imports = [impermanence.nixosModules.impermanence];
  nix = {
    settings = {
      auto-optimise-store = true;
      warn-dirty = false;
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
  nixpkgs.config.allowUnfree = true;
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/systemd/coredump"
      "/var/lib/docker"
      "/var/lib/waydroid"
      "/var/lib/flatpak"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.zoriya = {
      directories = [
        "downloads"
        "stuff"
        "projects"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        ".local/share/direnv"
        ".local/share/flatpak"
        ".local/share/waydroid"
        ".var"
        ".cache/flatpak"
        ".local/share/atuin"
        # Cache for sessions (keep website logged in, plugin downloaded...)
        ".mozilla"
        ".config/google-chrome"
        ".config/discord"
        ".config/YouTube\ Music"
        # Don't reinstall plugins on reboot
        ".local/share/nvim"
        ".local/state/nvim"
        # Gnome accounts
        ".config/goa-1.0"
        ".cache/gnome-control-center-goa-helper"
      ];
      files = [
        ".config/zsh/custom.zsh"
      ];
    };
  };

  fileSystems."/home/zoriya/wallpapers" = {
    device = "/home/zoriya/projects/flake/wallpapers/";
    fsType = "none";
    options = ["bind"];
  };
}
