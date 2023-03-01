{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.git;
in {
  options.modules.git = {enable = mkEnableOption "git";};

  config = mkIf cfg.enable {
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
      };

      userEmail = "zoe.roux@zoriya.dev";
      userName = "Zoe Roux";
    };
  };
}
