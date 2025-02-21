{
  programs.git = {
    enable = true;
    ignores = [".envrc"];
    signing = {
      signByDefault = true;
      key = "~/.ssh/id_rsa.pub";
    };
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
      nuke =
        #bash
        ''
          !git reset --hard HEAD && git clean -df .
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
}
