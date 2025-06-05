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
        allowed-signers = "~/.ssh/allowed_signers";
      };
      git = {
        auto-local-bookmark = true;
      };
      core = {
        fsmonitor = "watchman";
      };
    };
  };
}
