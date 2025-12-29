{...}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Zoe Roux";
        email = "zoe.roux@zoriya.dev";
      };
      signing = {
        behavior = "own";
        backend = "ssh";
        key = "~/.ssh/id_rsa.pub";
        allowed-signers = "~/.ssh/allowed_signers";
      };
      git = {
        auto-local-bookmark = true;
      };
      fsmonitor = {
        backend = "watchman";
      };
    };
  };
}
