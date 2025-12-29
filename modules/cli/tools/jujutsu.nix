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
      remotes = {
        origin = {
          auto-track-bookmarks = "glob:*";
        };
        upstream = {
          auto-track-bookmarks = "exact:master | exact:main";
        };
      };
      fsmonitor = {
        backend = "watchman";
      };
    };
  };
}
