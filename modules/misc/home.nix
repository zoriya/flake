{pkgs, ...}: {
  imports = [
    ./zsh
    ./nvim
  ];

  programs.direnv.enable = true;
  programs.direnv.stdlib = builtins.readFile ./direnv.sh;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.config = {warn_timeout = "500h";};

  programs.git = {
    enable = true;
    ignores = [".envrc"];
    difftastic = {
      # This breaks telescope's git status and I don't want to debug why
      enable = false;
      display = "inline";
    };
    signing = {
      signByDefault = true;
      key = "~/.ssh/id_rsa.pub";
    };
    extraConfig = {
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      push.autoSetupRemote = true;
      init.defaultBranch = "master";
      push.default = "upstream";
      advice.diverging = false;
      rerere.enabled = true;
      rebase.updateRefs = true;
      rebase.autoStash = true;
      rebase.autoSquash = true;
      branch.sort = "-committerdate";
      # TODO: enable git maintenance
    };

    userEmail = "zoe.roux@zoriya.dev";
    userName = "Zoe Roux";
  };

  # programs.zellij = {
  #   enable = true;
  #   enableZshIntegration = true;
  # };
  # xdg.configFile."".text = ''
  #   copy_on_select false
  #   default_layout "compact"
  #   pane_frames false
  #
  #   keybinds clear-defaults=true {
  #     normal {
  #       bind "Ctrl t" { SwitchToMode "tmux"; }
  #     }
  #     {
  #       bind "[" { SwitchToMode "Scroll"; }
  #       bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
  #       bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
  #       bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
  #       bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
  #       bind "c" { NewTab; SwitchToMode "Normal"; }
  #       bind "," { SwitchToMode "RenameTab"; }
  #       bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
  #       bind "n" { GoToNextTab; SwitchToMode "Normal"; }
  #       bind "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
  #       bind "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
  #       bind "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
  #       bind "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }
  #       bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
  #       bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
  #       bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
  #       bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
  #       bind "o" { FocusNextPane; }
  #       bind "d" { Detach; }
  #       bind "Space" { NextSwapLayout; }
  #       bind "x" { CloseFocus; SwitchToMode "Normal"; }
  #     }
  #   }
  # '';
  # programs.zsh.sessionVariables = {
  #   ZELLIJ_AUTO_EXIT = true;
  # };

  home.packages = [
    (pkgs.writeShellScriptBin "tmux-sessionizer" (builtins.readFile ./tmux-sessionizer.sh))
  ];
  xdg.configFile."tmux/tmux.conf".text = ''
    unbind C-b
    set -g prefix C-t
    bind -N "Send the prefix key through to the application" t send-prefix

    set -g mouse on
    set -g status off
    set -g set-clipboard on

    set-window-option -g mode-keys vi
    bind v copy-mode
    bind -T copy-mode-vi i send -X cancel
    bind -T copy-mode-vi v send -X begin-selection
    bind -T copy-mode-vi V send -X select-line
    bind -T copy-mode-vi y send -X copy-selection -x
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection -x

    bind-key -r f run-shell "tmux neww tmux-sessionizer"
    bind-key -r C-h run-shell "tmux-sessionizer ~/projects/kyoo"
    bind-key -r C-s run-shell "tmux-sessionizer ~/projects/flake"
    bind-key -r C-n run-shell "tmux-sessionizer ~/projects/blog"
    bind-key -r C-g run-shell "tmux-sessionizer ~/work/pagga"
    bind-key -r C-c run-shell "tmux-sessionizer ~/work/Pay.Monitor"

    run-shell ${pkgs.tmuxPlugins.sensible.rtp}
    run-shell ${pkgs.tmuxPlugins.fzf-tmux-url.rtp}
  '';
  # terminal = "\$TERM";

  xdg.configFile."nixpkgs/config.nix".text = ''    {
      allowUnfree = true;
    }'';

  # Allow gsettings to work
  xdg.systemDirs.data = [
    "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
  ];

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

  home.stateVersion = "22.11";
}
