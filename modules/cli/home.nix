{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./zsh
    ./tools/git.nix
    ./tools/jujutsu.nix
    ./tools/tmux.nix
  ];

  programs.opencode = {
    enable = true;
    settings = {
      theme = "catppuccin";
      keybinds = {
        variant_cycle = "ctrl+n";
        input_clear = "ctrl+u";
        session_interrupt = "ctrl+d";
        app_exit = "<leader>q";
        input_submit = "ctrl+s";
        input_newline = "return";
      };
    };
  };

  xdg.configFile."nixpkgs/config.nix".text = ''    {
      allowUnfree = true;
      android_sdk.accept_license = true;
    }'';

  # For virt-manager to detect hypervisor
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  # Use geoclue2 for weather location
  dconf.settings = {
    "org/gnome/shell/weather" = {
      automatic-location = true;
    };
  };

  systemd.user.services.download-clears = let
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
  };

  systemd.user.timers.download-clears = {
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
