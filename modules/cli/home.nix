{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./zsh
    ./tools/git.nix
    ./tools/jujutsu.nix
    ./tools/tmux.nix
  ];

  home.packages = [pkgs.claude-mux];

  programs.claude-code = {
    enable = true;
    configDir = "${config.xdg.configHome}/claude";
    # settings.json is installed as a writable file in the activation below instead
    # Claude needs to update it at runtime (e.g. model effort via the slash command).

    skills.new-session = ''
      ---
      name: new-session
      description: Spawn a separate Claude Code session to work on a described task, handing it a self-contained prompt built from the current conversation. Use when the user asks to "create/spawn/start a new session", "open a new claude for X", "hand this off to another session", or "do that in a separate session".
      ---

      # New session

      Spawn a fresh Claude Code session that works on what the user described,
      in parallel with this one. It runs detached in the background and is
      resumable like any other session, so the user picks it up when it is done.

      ## Steps

      1. Work out the task and the project directory — the new session runs in
         whatever directory you launch it from, so `cd` there. Default to the
         current working directory. Only ask the user something if the task
         itself is ambiguous, not to confirm details you can read from the
         conversation or the repo.

      2. Write the prompt to a file (the scratchpad dir if this session has one,
         otherwise `mktemp`). The new session shares **nothing** with this one
         and nobody is watching it work, so the prompt must stand on its own and
         must not ask questions back. Include, in plain prose:
         - the goal, stated as a concrete task;
         - the background from this conversation the new session would otherwise
           have to rediscover (what was tried, what failed, decisions already
           made and why);
         - the files that matter, as absolute or repo-relative paths — point at
           files rather than pasting large chunks of them;
         - constraints and non-goals: what must not change, what is out of scope;
         - how to know it worked (a command to run, a behaviour to check).

         Do not restate the user's global CLAUDE.md rules — the new session
         reads them itself. Write it as instructions to the new session, not as
         a summary of this conversation.

      3. Launch it detached, with an id of your own so you can report it:

         ```sh
         id=$(uuidgen)
         setsid claude -p --session-id "$id" "$(cat /path/to/prompt.md)" >"/tmp/claude-$id.log" 2>&1 &
         echo "$id"
         ```

         `setsid` keeps it alive after the command returns, and it must be
         backgrounded — do not wait for it.

      4. Tell the user, briefly, what the new session was told to do, and give
         them the session id (they resume it with `claude --resume <id>`, and it
         is in their session picker). Do not do the task yourself afterwards
         unless the user asks.
    '';
  };

  home.activation.claudeWritableSettings = ''
    install -Dm644 ${(pkgs.formats.json {}).generate "claude-code-settings.json" {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      theme = "auto";
      awaySummaryEnabled = false;
      autoMemoryEnabled = false;
      env.CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
      permissions.defaultMode = "auto";
      statusLine = {
        type = "command";
        command = let
          claudeStatusLine = pkgs.writeShellScript "claude-statusline" ''
            cat | ${lib.getExe pkgs.jq} -r '
              def fmt_tokens: if . >= 1000 then "\(. / 1000 | round)k" else "\(.)" end;
              (.model.display_name + (if .effort.level then " " + .effort.level else "" end)) as $model |
              (.context_window // {}) as $ctx |
              (.cost // {}) as $cost |
              [
                $model,
                (if $ctx.used_percentage then
                  "\($ctx.used_percentage)% of \($ctx.context_window_size | fmt_tokens)"
                else empty end),
                (if $ctx.current_usage then
                  "in \($ctx.current_usage.input_tokens | fmt_tokens) out \($ctx.current_usage.output_tokens | fmt_tokens)" +
                  (if $ctx.current_usage.cache_read_input_tokens > 0 then
                    " cache \($ctx.current_usage.cache_read_input_tokens | fmt_tokens)"
                  else "" end)
                else empty end),
                (if .rate_limits.five_hour.used_percentage then "5h \(.rate_limits.five_hour.used_percentage | round)%" else empty end),
                (if $cost.total_cost_usd then "$\($cost.total_cost_usd * 100 | round / 100)" else empty end)
              ] | join(" · ")'
          '';
        in "${claudeStatusLine}";
        padding = 0;
      };
      hooks.Stop = [
        {
          hooks = [
            {
              type = "command";
              command = let
                claudeNotify = pkgs.writeShellScript "claude-notify" (
                  let
                    parse = ''
                      input=$(cat)
                      name=$(echo "$input" | ${lib.getExe pkgs.jq} -r 'if .session_name then .session_name else (.cwd | split("/") | last) end')
                    '';
                  in
                    if pkgs.stdenv.isDarwin
                    then ''
                      ${parse}
                      osascript -e "display notification \"Response complete\" with title \"Claude Code · $name\""
                    ''
                    else ''
                      ${parse}
                      ${pkgs.libnotify}/bin/notify-send "Claude Code · $name" "Response complete"
                    ''
                );
              in "${claudeNotify}";
            }
            {
              type = "command";
              command = "${lib.getExe pkgs.claude-mux} hook --status idle";
            }
          ];
        }
      ];

      hooks.UserPromptSubmit = [
        {hooks = [{type = "command"; command = "${lib.getExe pkgs.claude-mux} hook --status running";}];}
      ];
      hooks.Notification = [
        {hooks = [{type = "command"; command = "${lib.getExe pkgs.claude-mux} hook --status questions";}];}
      ];
      hooks.SessionStart = [
        {hooks = [{type = "command"; command = "${lib.getExe pkgs.claude-mux} hook --status idle";}];}
      ];
      hooks.SessionEnd = [
        {hooks = [{type = "command"; command = "${lib.getExe pkgs.claude-mux} hook --status closed";}];}
      ];
    }} "${config.xdg.configHome}/claude/settings.json"
  '';

  home.activation.claudeRemoteControl = ''
    f="${config.xdg.configHome}/claude/.claude.json"
    [ -e "$f" ] || echo '{}' >"$f"
    ${lib.getExe pkgs.jq} '.remoteControlAtStartup = true' "$f" >"$f.tmp" && mv "$f.tmp" "$f"
  '';

  # path is persisted at first launch, reset it to hot-reload.
  home.activation.claudeMuxReload = ''
    export TMUX_TMPDIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export PATH="${pkgs.tmux}/bin:$PATH"
    ${lib.getExe pkgs.claude-mux} reload || true
  '';

  xdg.configFile."claude/CLAUDE.md".text = ''
    # Global instructions

    - Never use git, we use jj instead.
    - Never edit jj (or even worse git) state, don't jj commit/edit/describe/split in a workspace you don't own, unless specifically asked to
    - Never ever push or talk about it
    - when fetching github content/pr/issues/wha, use the `gh` cli.
    - NEVER ever create issues/pr/write on github.
    - keep functions/variables inlined, no clean-code here.
  '';

  xdg.configFile."claude/keybindings.json".text = builtins.toJSON {
    "$schema" = "https://www.schemastore.org/claude-code-keybindings.json";
    "$docs" = "https://code.claude.com/docs/en/keybindings";
    bindings = [
      {
        context = "Chat";
        bindings = {
          "ctrl+s" = "chat:submit";
          "ctrl+shift+s" = "chat:stash";
          "enter" = "chat:newline";
          "ctrl+d" = "chat:cancel";
          "ctrl+u" = "chat:stash";
          "ctrl+z" = "chat:undo";
          "ctrl+y" = "chat:undo";
          "ctrl+shift+z" = "chat:redo";
          "ctrl+shift+y" = "chat:redo";
          "escape" = "chat:cancel";
          "ctrl+x e" = "chat:externalEditor";
        };
      }
      {
        context = "Autocomplete";
        bindings = {
          "ctrl+h" = "autocomplete:accept";
        };
      }
    ];
  };

  programs.opencode = {
    enable = true;
    settings = {
      small_model = "github-copilot/gpt-5-mini";
      autoupdate = false;
      plugin = ["@mohak34/opencode-notifier"];
    };
    tui = {
      theme = "catppuccin";
      diff_style = "stacked";
      keybinds = {
        variant_cycle = "ctrl+n";
        input_clear = "ctrl+u";
        session_interrupt = "ctrl+d";
        app_exit = "<leader>q";
        input_submit = "ctrl+s";
        input_newline = "return";
        input_undo = "ctrl+y,ctrl+z";
        input_redo = "ctrl+shift+y,ctrl+shift+z";
        terminal_suspend = "none";
      };
    };
  };

  xdg.configFile."opencode/opencode-notifier.json".text = builtins.toJSON {
    sound = false;
    showSessionTitle = true;
  };

  xdg.configFile."nixpkgs/config.nix".text = ''    {
      allowUnfree = true;
      android_sdk.accept_license = true;
    }'';

  # For virt-manager to detect hypervisor
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  # Use geoclue2 for weather location
  dconf.settings = {
    "org/gnome/shell/weather" = {
      automatic-location = true;
    };
  };

  systemd.user.services.download-clears = let
    script = pkgs.writeShellScriptBin "download-clears" ''
      find ~/downloads -mtime +30 -delete
    '';
  in {
    Unit = {
      Description = "Clean up files older than 30 days in Downloads";
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe script;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  systemd.user.timers.download-clears = {
    Unit = {
      Description = "Clear old downloads";
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };

  home.stateVersion = "22.11";
}
