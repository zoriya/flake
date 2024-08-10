{
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/bluetooth"
      "/var/lib/systemd/coredump"
      "/var/lib/docker"
      "/var/lib/libvirt"
      "/var/lib/qemu"
      "/var/lib/nixos-containers"
      "/var/lib/lxd"
      "/var/lib/waydroid"
      "/var/lib/flatpak"
      "/var/lib/tcc"
      "/var/lib/flood"
      "/var/lib/transmission"
      "/var/lib/acme"
      "/etc/NetworkManager/system-connections"
      "/etc/tailord/"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/var/snapraid.content"
      "/var/cache/locatedb"
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
        ".cache/direnv"
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
        ".config/gh"
        # Don't reinstall plugins on reboot
        ".local/share/nvim"
        ".local/state/nvim"
        # Gnome accounts
        ".config/goa-1.0"
        ".cache/gnome-control-center-goa-helper"
        # Games directory for lutris
        ".local/lutris"
        ".local/games"
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
