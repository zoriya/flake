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
        enable = true;
        display = "inline";
      };
      signing = {
        signByDefault = true;
        key = "~/.ssh/id_rsa.pub";
      };
      extraConfig = {
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };

      userEmail = "zoe.roux@zoriya.dev";
      userName = "Zoe Roux";
    };
  };
}
