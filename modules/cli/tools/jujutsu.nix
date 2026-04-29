{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Zoe Roux";
        email = "zoe.roux@zoriya.dev";
      };
      signing = {
        behavior = "force";
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
      ui = {
        conflict-marker-style = "git";
      };
      templates = {
        draft_commit_description = ''
          concat(
            builtin_draft_commit_description,
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };
    };
  };

  programs.jjui = {
    enable = true;
    settings = {
      actions = [
        {
          name = "tug";
          desc = "Tug previous bookmark";
          lua =
            #lua
            ''
              jj("bookmark", "move", "--from", "closest_bookmark(@)", "--to", context.change_id())
              revisions.refresh({})
            '';
        }
      ];
      bindings = [
        {
          key = "t";
          action = "tug";
          scope = "revisions";
          desc = "Tug";
        }
        # bindings bellows are just for ctrl+c as cancel
        {
          key = ["esc" "ctrl+c"];
          action = "ui.cancel";
          scope = "ui";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "help.cancel";
          scope = "help";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "help.cancel";
          scope = "help.filter";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revset.cancel";
          scope = "revset";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.cancel";
          scope = "revisions";
          desc = "clear selection";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.quick_search.clear";
          scope = "revisions.quick_search";
          desc = "clear";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.rebase.cancel";
          scope = "revisions.rebase";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.squash.cancel";
          scope = "revisions.squash";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.revert.cancel";
          scope = "revisions.revert";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.duplicate.cancel";
          scope = "revisions.duplicate";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c" "left" "h"];
          action = "revisions.details.cancel";
          scope = "revisions.details";
          desc = "close";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.details.confirmation.cancel";
          scope = "revisions.details.confirmation";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.evolog.cancel";
          scope = "revisions.evolog";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.abandon.cancel";
          scope = "revisions.abandon";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.absorb.cancel";
          scope = "revisions.absorb";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.set_parents.cancel";
          scope = "revisions.set_parents";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.inline_describe.cancel";
          scope = "revisions.inline_describe";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.set_bookmark.cancel";
          scope = "revisions.set_bookmark";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.target_picker.cancel";
          scope = "revisions.target_picker";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.ace_jump.cancel";
          scope = "revisions.ace_jump";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "revisions.quick_search.input.cancel";
          scope = "revisions.quick_search.input";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "status.input.cancel";
          scope = "status.input";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "file_search.cancel";
          scope = "file_search";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "bookmarks.cancel";
          scope = "bookmarks";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "bookmarks.cancel";
          scope = "bookmarks.filter";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "git.cancel";
          scope = "git";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "git.cancel";
          scope = "git.filter";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "oplog.close";
          scope = "oplog";
          desc = "close";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "oplog.quick_search.clear";
          scope = "oplog.quick_search";
          desc = "clear";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "undo.cancel";
          scope = "undo";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "redo.cancel";
          scope = "redo";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "ui.cancel";
          scope = "diff";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "command_history.close";
          scope = "command_history";
          desc = "close";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "input.cancel";
          scope = "input";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "password.cancel";
          scope = "password";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "choose.cancel";
          scope = "choose";
          desc = "cancel";
        }
        {
          key = ["esc" "ctrl+c"];
          action = "choose.cancel";
          scope = "choose.filter";
          desc = "cancel";
        }
      ];
    };
  };
}
