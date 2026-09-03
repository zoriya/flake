{
  impermanence,
  user,
  config,
  lib,
  utils,
  ...
}: let
  root = config.fileSystems."/";
  wipe = root.fsType == "btrfs" && lib.elem "subvol=@root" root.options;
in {
  imports = [
    impermanence.nixosModules.impermanence
  ];

  # `/` is a disposable btrfs subvolume. the previous root is renamed `old_roots/<mtime>`
  boot.initrd.systemd = lib.mkIf wipe {
    enable = true;
    services.wipe-root = {
      wantedBy = ["initrd.target"];
      after = ["initrd-root-device.target" "${utils.escapeSystemdPath root.device}.device"];
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /wipe
        mount -o subvol=/ ${root.device} /wipe

        mkdir -p /wipe/old_roots
        if [ -e /wipe/@root ]; then
          mv /wipe/@root /wipe/old_roots/"$(stat -c %Y /wipe/@root)"
        fi
        for old in $(ls -1 /wipe/old_roots | sort -n | head -n -3); do
          btrfs subvolume delete -R "/wipe/old_roots/$old"
        done

        btrfs subvolume create /wipe/@root

        if [ -e /wipe/@tmp ]; then
          btrfs subvolume delete -R /wipe/@tmp
        fi
        btrfs subvolume create /wipe/@tmp
        chmod 1777 /wipe/@tmp

        umount /wipe
      '';
    };
  };

  services.btrfs.autoScrub.enable = lib.mkIf wipe true;

  environment.persistence."/persist" = {
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
      "/var/lib/acme"
      "/etc/NetworkManager/system-connections"
      "/var/cache/locate"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/var/snapraid.content"
    ];
    users.${user} = {
      directories = [
        "downloads"
        "stuff"
        "projects"
        "work"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        ".local/share/direnv"
        ".cache/direnv"
        ".local/share/flatpak"
        ".local/share/waydroid"
        ".local/share/bottles"
        ".local/share/tmux-sessionizer"
        ".var"
        ".kube"
        ".cache/flatpak"
        ".local/share/atuin"
        # Cache for sessions (keep website logged in, plugin downloaded...)
        ".mozilla"
        ".zen"
        ".config/google-chrome"
        ".config/discord"
        ".config/Slack"
        ".config/vesktop"
        ".config/YouTube\ Music"
        ".config/gh"
        ".config/github-copilot"
        # orca slicer
        ".config/OrcaSlicer"
        ".local/share/orca-slicer"
        # Don't reinstall plugins on reboot
        ".local/share/nvim"
        ".local/state/nvim"
        # claude-code
        ".config/claude"
        # claude-mux (persisted rc-enabled project list + session status)
        ".local/state/claude-mux"
        # opencode
        ".config/opencode"
        ".cache/opencode"
        ".local/share/opencode"
        ".local/state/opencode"
        # Gnome accounts
        ".config/goa-1.0"
        ".cache/gnome-control-center-goa-helper"
        # Games directory for lutris
        ".local/lutris"
        ".local/games"
        # Huge cache & long download i want to stay cache
        ".cache/nix"
        ".cache/.bun"
        ".cache/yarn"
        ".cache/go-build"
        # android studio
        ".cache/Google"
        ".config/android"
        ".config/.android"
      ];
      files = [
        ".config/zsh/custom.zsh"
      ];
    };
  };

  fileSystems."/home/${user}/wallpapers" = {
    device = "/home/${user}/projects/flake/default/wallpapers/";
    fsType = "none";
    options = ["bind" "nofail"];
  };
}
