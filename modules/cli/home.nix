{
  pkgs,
  lib,
  ...
}: let
  jq = lib.getExe pkgs.jq;

  claudeStatusLine = pkgs.writeShellScript "claude-statusline" ''
    cat | ${jq} -r '
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

  claudeNotify = pkgs.writeShellScript "claude-notify" (
    let
      parse = ''
        input=$(cat)
        name=$(echo "$input" | ${jq} -r 'if .session_name then .session_name else (.cwd | split("/") | last) end')
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
in {
  imports = [
    ./zsh
    ./tools/git.nix
    ./tools/jujutsu.nix
    ./tools/tmux.nix
  ];

  programs.claude-code = {
    enable = true;
    settings = {
      model = "claude-opus-4-6";
      theme = "auto";
      permissions.defaultMode = "auto";
      statusLine = {
        type = "command";
        command = "${claudeStatusLine}";
        padding = 0;
      };
      hooks.Stop = [
        {
          hooks = [
            {
              type = "command";
              command = "${claudeNotify}";
            }
          ];
        }
      ];
    };
  };

  home.file.".claude/keybindings.json".text = builtins.toJSON {
    "$schema" = "https://www.schemastore.org/claude-code-keybindings.json";
    "$docs" = "https://code.claude.com/docs/en/keybindings";
    bindings = [
      {
        context = "Chat";
        bindings = {
          "ctrl+s" = "chat:submit";
          "enter" = "chat:newline";
          "ctrl+d" = "chat:cancel";
          "ctrl+u" = "chat:clearInput";
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
