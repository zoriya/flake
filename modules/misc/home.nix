{
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
      pull.ff = "only";
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

  programs.tmux = {
    enable = true;
    escapeTime = 0;
    terminal = "\$TERM";
    shortcut = "t";
    mouse = true;
    aggressiveResize = true;
    clock24 = true;
    historyLimit = 50000;
    extraConfig = ''
    set -g status off
    set focus-events on
    set -g set-clipboard on
    '';
  };

  xdg.configFile."nixpkgs/config.nix".text = ''    {
      allowUnfree = true;
    }'';

  home.stateVersion = "22.11";
}
