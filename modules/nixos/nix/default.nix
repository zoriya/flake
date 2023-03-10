{
  lib,
  config,
  impermanence,
  ...
}: let
  cfg = config.nixconf;
in {
  imports = [ impermanence.nixosModules.impermanence ];
  options.nixconf = {enable = lib.mkEnableOption "nix";};
  config = lib.mkIf cfg.enable {

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
          "wallpapers"
          { directory = ".gnupg"; mode = "0700"; }
          { directory = ".ssh"; mode = "0700"; }
          ".local/share/direnv"
          ".local/share/flatpak"
          ".cache/flatpak"
          ".local/share/atuin"
          # Cache for sessions (keep website logged in, plugin downloaded...)
          ".config/google-chrome"
          ".config/discord"
          # Don't reinstall plugins on reboot
          ".local/share/nvim"
          ".local/state/nvim"
        ];
        files = [
          ".config/zsh/custom.zsh"
        ];
      };
    };
  };
}
