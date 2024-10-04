{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    eza
    viu
    htop-vim
    tldr
    fd
    duf
    ncdu
    ripgrep
    psmisc
    fzf
    nix-your-shell
    mosh
    unzip
    usbutils
    pciutils
    sshfs-fuse
    zip
    scc
    bc
    glow
    gh
    alejandra
    nodePackages.http-server
    nodePackages.live-server
  ];

  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
    settings = {
      update_check = false;
      show_preview = true;
    };
  };

  programs.bat = {
    enable = true;
    config.theme = "base16";
  };

  programs.command-not-found.enable = false;
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.less.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      format = lib.concatStrings [
        "$fill"
        "$hostname"
        "$python"
        "$nix_shell"
        "$line_break"
        "$directory"
        "[(\\($git_branch$git_commit$git_status$git_state\\) )](green)"
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
        style = "bold fg:#00AFFF";
      };

      git_branch = {
        format = "([($branch(: $remote_branch))]($style))";
        style = "green";
      };

      git_commit = {
        format = "[( $hash$tag)]($style)";
        style = "green";
        only_detached = true;
        tag_disabled = false;
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
        format = ''[$state( $progress_current/$progress_total)]($style)'';
        style = "bright-black";
      };

      status = {
        format = " [($symbol ($signal_name )$status)]($style)";
        pipestatus_format = "[$symbol $pipestatus]($style)";
        pipestatus_segment_format = "[($signal_name )$status]($style)";
        symbol = "x";
        pipestatus = true;
        disabled = false;
      };

      cmd_duration = {
        format = " [$duration]($style)";
      };

      jobs = {
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
    };
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    # already handled at system level
    enableCompletion = false;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      # ls/exa stuff
      l = "ls -l";
      ll = "ls -l";
      la = "ls -la";
      lla = "ls -la";
      lc = "l --color";
      exa = "eza --group";
      lg = "exa -l --git-ignore";
      ls = "exa";
      lt = "exa --tree";
      tree = "exa --tree";

      # git stuff
      s = "git status";
      gs = "git status";
      gl = "git log";
      gu = "git pull";
      gcam = "git commit --amend";
      gcamn = "git commit --amend --no-edit";

      # Misc
      dc = "docker-compose";
      dcd = "docker-compose -f docker-compose.dev.yml";
      op = "xdg-open";
      py = "python3 2> /dev/null || nix shell nixpkgs#python3 -c python3";
      jctl = "sudo journalctl -n 1000 -fu";
      sloc = "scc";
    };

    plugins = [
      {
        name = "you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.zsh";
      }
      {
        name = "custom";
        src = ./.;
        file = "./custom.zsh";
      }
      {
        name = "sudo";
        src = pkgs.oh-my-zsh;
        file = "share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh";
      }
      {
        name = "git";
        src = pkgs.oh-my-zsh;
        file = "share/oh-my-zsh/plugins/git/git.plugin.zsh";
      }
      {
        name = "copypath";
        src = pkgs.oh-my-zsh;
        file = "share/oh-my-zsh/plugins/copypath/copypath.plugin.zsh";
      }
      {
        name = "copyfile";
        src = pkgs.oh-my-zsh;
        file = "share/oh-my-zsh/plugins/copyfile/copyfile.plugin.zsh";
      }
    ];
    initExtra = builtins.readFile ./init.zsh;

    # zprof.enable = true;

    sessionVariables = {
      YSU_MESSAGE_FORMAT = "Alias: %alias - %command";
      YSU_IGNORED_ALIASES = ''("g" "-" "~" "/" ".." "..." "...." "....." "md" "rd")'';
      DIRENV_LOG_FORMAT = "";
      WORDCHARS = "_-*";
    };
  };
}
