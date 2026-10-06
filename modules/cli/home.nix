{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./zsh
    ./ai/claude.nix
    ./ai/opencode.nix
    ./tools/git.nix
    ./tools/jujutsu.nix
    ./tools/tmux.nix
  ];

  xdg.configFile."nixpkgs/config.nix".text = ''    {
      allowUnfree = true;
      android_sdk.accept_license = true;
    }'';

  dconf.settings = {
    # For virt-manager to detect hypervisor
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
    # Use geoclue2 for weather location
    "org/gnome/shell/weather".automatic-location = true;
  };

  # home-manager warns on non-linux `systemd.user`, and darwin imports this file too.
  systemd.user.services.download-clears = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (let
    script = pkgs.writeShellScriptBin "download-clears" ''
      find ~/downloads -mtime +30 -delete
    '';
  in {
    Unit = {
      Description = "Clean up files older than 30 days in Downloads";
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe script;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  });

  systemd.user.timers.download-clears = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Clear old downloads";
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };

  home.stateVersion = "22.11";
}
