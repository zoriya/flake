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
      fsmonitor = {
        backend = "watchman";
      };
      remotes = {
        origin = {
          auto-track-bookmarks = "glob:*";
        };
        upstream = {
          auto-track-bookmarks = "exact:master | exact:main";
        };
      };
      aliases = {
        init = ["git" "init" "--colocate"];
        tug = ["bookmark" "move" "--from" "closest_bookmark(@)" "--to" "closest_pushable(@)"];
      };
      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "closest_pushable(to)" = ''heads(::to & mutable() & ~description(exact:" ") & (~empty() | merges()))'';
      };
    };
  };
}
