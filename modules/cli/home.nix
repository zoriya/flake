{pkgs, ...}: {
  imports = [
    ./zsh
  ];
  programs.direnv = {
    enable = true;
    stdlib = builtins.readFile ./direnv.sh;
    nix-direnv.enable = true;
    config = {warn_timeout = "500h";};
  };

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
    # TODO: unstable feature not in my fork yet
    # maintenance = {
    #   enable = false;
    #   # TODO: figure out a way to specify all repositories in ~/projects & ~/work at run time
    #   repositories = [];
    # };
    aliases = {
      master =
        #bash
        ''
          !git symbolic-ref --short refs/remotes/$(git remote | head -n 1)/HEAD | sed 's@.*/@@'
        '';
      cleanup =
        #bash
        ''
          !git branch --merged | grep -vE "^([+*]|\s*($(git master))\s*$)" | xargs git branch --delete 2>/dev/null
        '';
    };
    extraConfig = {
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      push.autoSetupRemote = true;
      push.default = "upstream";
      pull.ff = "only";
      init.defaultBranch = "master";
      advice.diverging = false;
      rerere.enabled = true;
      rebase.updateRefs = true;
      rebase.autoStash = true;
      rebase.autoSquash = true;
      branch.sort = "-committerdate";
      # Disable hooks
      core.hookspath = "/dev/null";
      # Break compat with older versions of git (and systems that doesn't support mtime) to have better performances
      feature.manyFiles = true;
    };

    userEmail = "zoe.roux@zoriya.dev";
    userName = "Zoe Roux";
  };

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
    set -g focus-events on

    set-window-option -g mode-keys vi
    bind-key v copy-mode
    bind-key -T copy-mode-vi i send -X cancel
    bind-key -T copy-mode-vi v send -X begin-selection
    bind-key -T copy-mode-vi V send -X select-line
    bind-key -T copy-mode-vi y send -X copy-selection -x
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection -x

    bind-key [ copy-mode \; send-keys -X previous-prompt
    bind-key ] copy-mode \; send-keys -X next-prompt
    bind-key -T copy-mode-vi [ send-keys -X previous-prompt
    bind-key -T copy-mode-vi ] send-keys -X next-prompt

    bind-key f run-shell "tmux neww tmux-sessionizer"
    bind-key C-h run-shell "tmux-sessionizer ~/projects/kyoo"
    bind-key C-s run-shell "tmux-sessionizer ~/projects/flake"
    bind-key C-n run-shell "tmux-sessionizer ~/projects/blog"

    run-shell ${pkgs.tmuxPlugins.sensible.rtp}
    run-shell ${pkgs.tmuxPlugins.fzf-tmux-url.rtp}

    # https://github.com/tmux/tmux/issues/4162
    set -gu default-command
    set -g default-shell "$SHELL"
  '';

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

  home.stateVersion = "22.11";
}
