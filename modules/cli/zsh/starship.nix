{lib, ...}: {
  programs.starship = {
    enable = true;
    # integrate manually
    enableZshIntegration = false;
    settings = {
      add_newline = false;

      format = lib.concatStrings [
        "$fill"
        "$hostname"
        "$python"
        "$nix_shell"
        "$container"
        "$line_break"
        "$directory"
        "[(\\($git_branch$git_commit$git_status$git_state\\) )](green)"
        "$kubernetes"
        "$shlvl"
        "$character"
      ];

      right_format = lib.concatStrings [
        "$cmd_duration"
        "$status"
        "$jobs"
      ];

      fill = {
        symbol = "·";
        style = "fg:#808080";
      };

      directory = {
        truncate_to_repo = false;
        fish_style_pwd_dir_length = 1;
        read_only = ":ro";
        style = "bold fg:#00AFFF";
      };

      git_branch = {
        format = "([($branch(: $remote_branch))]($style))";
        only_attached = true;
        style = "green";
      };

      git_commit = {
        format = "[($hash$tag)]($style)";
        style = "green";
        only_detached = true;
        tag_disabled = false;
        tag_symbol = " ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style))";
        style = "yellow";
        ahead = " ⇡$count";
        behind = " ⇣$count";
        diverged = "";
        conflicted = " =$count";
        untracked = " ?$count";
        stashed = " *$count";
        modified = " !$count";
        staged = " +$count";
        deleted = "";
        renamed = "";
      };

      git_state = {
        format = "( [$state( $progress_current/$progress_total)]($style))";
      };

      status = {
        format = " [($symbol$status(-$signal_name))]($style)";
        pipestatus_format = "[$symbol$pipestatus]($style)";
        pipestatus_segment_format = "[($signal_name )$status]($style)";
        symbol = "x";
        pipestatus = true;
        disabled = false;
      };

      kubernetes = {
        format = "[$context(/$namespace) ]($style)";
        disabled = false;
        contexts = [
          {
            context_pattern = "colima-lucca-apps";
            context_alias = "lucca";
          }
        ];
      };

      cmd_duration = {
        format = " [$duration]($style)";
      };

      jobs = {
        symbol = "&";
        format = " [$symbol$number]($style)";
      };

      python = {
        format = "[( \($virtualenv\))]($style)";
      };

      nix_shell = {
        format = "[\( $name\) nix]($style)";
        style = "cyan";
        heuristic = true;
      };

      container = {
        format = "[ $name]($style)";
      };

      hostname = {
        format = "[ $ssh_symbol$hostname]($style)";
      };

      shlvl = {
        disabled = false;
        format = "[$symbol]($style)";
        repeat = true;
        symbol = "❯";
        repeat_offset = 1;
        threshold = 0;
      };
    };
  };
}
