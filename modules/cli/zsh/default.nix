{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      eza
      viu
      htop-vim
      tldr
      fd
      duf
      ncdu
      ripgrep
      fzf
      nix-your-shell
      unzip
      sshfs-fuse
      zip
      scc
      bc
      glow
      gh
      yq
      alejandra
      nodePackages.http-server
      nodePackages.live-server
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      usbutils
      pciutils
      psmisc
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
        only_attached = true;
        style = "green";
      };

      git_commit = {
        format = "[($hash$tag)]($style)";
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

      hostname = {
        format = "[ $ssh_symbol$hostname]($style)";
      };
    };
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
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
      k = "kubectl";
      op = "xdg-open";
      py = "python3 2> /dev/null || nix shell nixpkgs#python3 -c python3";
      jctl = "sudo journalctl -n 1000 -fu";
      sloc = "scc";
      mi = "mediainfo";
      # viu doesn't work with tmux, icat does. using that while waiting
      viu = "kitty +kitten icat";
      icat = "kitty +kitten icat";
    };
    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
    };

    plugins = [
      {
        name = "you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
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
        name = "clipcopy"; # dependency of copypath & copyfile
        src = pkgs.oh-my-zsh;
        file = "share/oh-my-zsh/lib/clipboard.zsh";
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
    initExtraFirst = ''
      # Create a new tmux session (with a random name) and attach.
      if [[ -z "$TMUX" ]]; then
      	exec tmux -u new-session -s "#$(hexdump -n 4 -v -e '/1 "%02X"' /dev/urandom)"
      elif [[ $SHLVL -eq 1 ]]; then
        session=$(tmux display-message -p "#S")
        # kill current sesion if we are quiting the only pane
        function __onExit {
          if [[ $(tmux list-panes -s -t $session | wc -l) == 1 ]]; then
            tmux kill-session -t $session
          fi
        }
        trap __onExit EXIT
      fi
    '';
    initExtraBeforeCompInit = builtins.readFile ./comp.zsh;
    completionInit = ''
      # The globbing is a little complicated here:
      # - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
      # - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
      # - '.' matches "regular files"
      # - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.autoload -Uz compinit
      autoload -Uz compinit
      if [[ -n $ZSH_CACHE_DIR/.zcompdump(#qN.mh+24) ]]; then
      	compinit;
      else
      	compinit -C;
      fi;
    '';
    initExtra = builtins.readFile ./init.zsh;

    envExtra = ''
      # disable /etc/zshrc & co (nixos one is really bad)
      setopt no_global_rcs
    '';

    # zprof.enable = true;

    sessionVariables = {
      YSU_MESSAGE_FORMAT = "Alias: %alias - %command";
      YSU_IGNORED_ALIASES = ''("g" "-" "~" "/" ".." "..." "...." "....." "md" "rd")'';
      DIRENV_LOG_FORMAT = "";
      WORDCHARS = "_-*";
    };
  };
}
