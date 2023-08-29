{
  lib,
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
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
      advice.diverging = false;
    };

    userEmail = "zoe.roux@zoriya.dev";
    userName = "Zoe Roux";
  };
}
