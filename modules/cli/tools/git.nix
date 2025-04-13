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
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      push = {
        default = "upstream";
        autoSetupRemote = true;
      };
      pull.ff = "only";
      init.defaultBranch = "master";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      advice.diverging = false;
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      rebase = {
        updateRefs = true;
        autoStash = true;
        autoSquash = true;
      };
      diff = {
        # newer & better diff algo, why is this not the default?
        algorithm = "histogram";
        colorMoved = "plain";
        renames = true;
        # use actually understandable prefixes (c/, i/ & w/) instead of a/ b/
        mnemonicPrefix = true;
      };
      # show diff in commit window
      commit.verbose = true;
      core = {
        # Disable hooks (i think i need to run it on each repo too, idk)
        hookspath = "/dev/null";
        fsmonitor = true;
        untrackedCache = true;
      };
      # Break compat with older versions of git (and systems that doesn't support mtime) to have better performances
      feature.manyFiles = true;

      clean.requireForce = false;

      url = {
        "ssh://git@github.com" = {
          insteadOf = "https://github.com";
        };
      };
    };

    userEmail = "zoe.roux@zoriya.dev";
    userName = "Zoe Roux";
  };
}
