{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
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
      cat = "\bat -pp";
      bat = "bat -p";

      # git stuff
      gs = "git status";
      gl = "git log";
      gu = "git pull";
      gur = "git pull --rebase";
      gum = "git pull origin $(git master)";
      gdm = "git diff origin/$(git master)";
      gurm = "git pull --rebase origin $(git master)";
      gswm = "git switch $(git master)";
      grbm = "git rebase origin/$(git master)";
      grbmi = "git rebase origin/$(git master) -i";
      grhhm = "grhh origin/$(git master)";
      grhsm = "grhs origin/$(git master)";
      grhho = "grhh @{u}";
      gmm = "git merge origin $(git master)";
      gcam = "git commit --amend";
      gcamn = "git commit --amend --no-edit";
      gcpf = "gaa && gcamn && gpf";
      gcpfn = "gcamn && gpf";

      # k8s
      k = "kubectl";
      kubectl = "kubecolor";
      kctx = "FZF_DEFAULT_OPTS='--height 10' kubectx";
      kns = "kubens";
      knsc = "kubectl config set-context --current --namespace ''";
      kg = "k get";
      kga = "kg $(k api-resources --verbs=list --namespaced -o name | paste -sd ,)";
      # use custom function to decode secrets data instead of a simple alias for kgy
      # kgy = "k get -o yaml";
      kgw = "k get -w";
      kd = "k describe";
      ka = "k apply";
      kaf = "k apply -f";
      ke = "k edit";
      kl = "k logs";
      kp = "k patch";
      kc = "k create";
      kcy = "kc -o yaml --dry-run=client";
      kr = "k rollout";
      krr = "k rollout restart";
      kpf = "k port-forward";
      kdel = "k delete";
      kdelf = "k delete -f";
      kcleanup = "kdel pod --field-selector status.phase==Failed -A; kdel pod --field-selector status.phase==Succeeded -A";

      # Misc
      dc = "docker compose";
      dcd = "docker compose -f $(setopt extendedglob; echo (../)#docker-compose.dev.yml)";
      op =
        if pkgs.stdenv.isLinux
        then "xdg-open"
        else "open";
      py = "python3 2> /dev/null || , python3";
      jctl = "sudo journalctl -n 1000 -fu";
      sloc = "scc";
      mi = "mediainfo";
      # habits & prevent conflicts with gnu-rename
      prename = "rename";
      # add labels, replace type by fstype, use a single mountpoint
      lsblk = "lsblk -o name,label,size,rm,ro,fstype,uuid,mountpoint";
      dr = "direnv reload";
      nixos-option = "nixos-option --flake ~/projects/flake";
      # i will never remember those flags
      ss =
        if pkgs.stdenv.isLinux
        then "ss -tlpun"
        else "netstat -anvp tcp | awk 'NR<3 || /LISTEN/'";

      # viu doesn't work with tmux, icat does. using that while waiting
      viu = "kitty +kitten icat";
      icat = "kitty +kitten icat";

      n = "$EDITOR";
      vim = "$EDITOR";
      vi = "$EDITOR";
      v = "$EDITOR";
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
    ];
    completionInit =
      #bash
      ''
        # disable zsh-autocomplete plugin compatibility (from zsh-completion-sync)
        zstyle ':completion-sync:compinit:compat:zsh-autocomplete' enabled false

        # The globbing is a little complicated here:
        # - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
        # - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
        # - '.' matches "regular files"
        # - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.autoload -Uz compinit
        autoload -Uz compinit

        source ${./zsh-completion-sync.plugin.zsh}

        if [[ -n $ZSH_CACHE_DIR/.zcompdump(#qN.mh+24) ]]; then
          compinit;
        else
          compinit -C;
        fi;

        # fix kubecolors completions
        # this needs to be executed BEFORE completions, contrary to what is done on nix's package:
        # https://github.com/NixOS/nixpkgs/blob/20fd9f95cede54a97eef269c80616a86dec213c9/pkgs/by-name/ku/kubecolor/package.nix#L50
        compdef kubecolor=kubectl
      '';

    initContent = let
      tmuxInit =
        #bash
        ''
          if command -v tmux > /dev/null; then
            # Create a new tmux session (with a random name) and attach.
            if [[ -z "$TMUX" ]]; then
              exec tmux -u new-session -s "#$(hexdump -n 4 -v -e '/1 "%02X"' /dev/urandom)"
            elif [[ $SHLVL -eq 1 ]]; then
              session=$(tmux display-message -p "#S")
              # kill current session if we are quitting the only pane
              function __onExit {
                if [[ $(tmux list-panes -s -t $session | wc -l) == 1 ]]; then
                  tmux kill-session -t $session
                fi
              }
              trap __onExit EXIT
            fi

            # execute arbitrary commands on startup since `zsh -sc` is not a real option :c
            if [[ -n CMD ]]; then
                # unset the cmd before executing it (for long processes)
                cmd=$CMD
                unset CMD
                if [[ -n $TMUX ]]; then
                    tmux set-environment -r CMD
                fi
                eval $cmd
            fi
          fi
        '';
    in
      lib.mkMerge [
        (lib.mkBefore tmuxInit)
        (lib.mkOrder 535 (builtins.readFile ./keymap.zsh))
        (lib.mkOrder 550 (builtins.readFile ./comp.zsh))
        (lib.mkOrder 901
          #bash
          ''
            unset HISTFILE
            setopt rm_star_silent
            setopt interactivecomments
            setopt autopushd

            # disable space between right prompt and end of line
            ZLE_RPROMPT_INDENT=0
          '')
        (lib.mkOrder 950 "source ${pkgs.gitstatus}/share/gitstatus/gitstatus.prompt.zsh")
        (lib.mkOrder 951 (builtins.readFile ./prompt.zsh))
        (lib.mkOrder 1000 (builtins.readFile ./init.zsh))
        (lib.mkOrder 1400 ''
          # only start atuin if it's in the path (fix distrobox or other temp fs issues)
          if command -v atuin > /dev/null && [[ $options[zle] = on ]]; then
            eval "$(atuin init zsh ${lib.escapeShellArgs config.programs.atuin.flags})"
          fi
        '')
        (lib.mkOrder 1410 "${lib.getExe pkgs.nix-your-shell} zsh | source /dev/stdin")
      ];

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

  home.sessionVariables = rec {
    EDITOR = "nvim";
    VISUAL = EDITOR;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = false;
    flags = ["--disable-up-arrow"];
    settings = {
      update_check = false;
      show_preview = true;
      style = "full";
      inline_height = 0;
      sync_address = "https://atuin.sdg.moe";
    };
  };

  programs.distrobox = {
    enable = pkgs.stdenv.isLinux; # this is not supported on macos
  };
  xdg.configFile."distrobox/distrobox.conf".text = ''
    container_name_default="archlinux"
    container_image_default="quay.io/toolbx/arch-toolbox:latest"
    container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user/zoriya:/etc/profiles/per-user/zoriya:ro"
  '';

  programs.bat = {
    enable = true;
    themes = {
      catppuccin-latte = {
        src = pkgs.catppuccin.override {
          variant = "latte";
          themeList = ["bat"];
        };
        file = "bat/Catppuccin Latte.tmTheme";
      };
      catppuccin-mocha = {
        src = pkgs.catppuccin.override {
          variant = "mocha";
          themeList = ["bat"];
        };
        file = "bat/Catppuccin Mocha.tmTheme";
      };
    };
    config = {
      theme-light = "catppuccin-latte";
      theme-dark = "catppuccin-mocha";
    };
  };

  programs.k9s = {
    enable = true;
    settings = {
      k9s = {
        ui = {
          skin = "transparent";
        };
      };
    };
    skins = {
      transparent = ./k9s-transparent.yaml;
    };
  };

  programs.less.enable = true;

  programs.direnv = {
    enable = true;
    stdlib =
      #bash
      ''
        : "''${XDG_CACHE_HOME:=$HOME/.cache}"

        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
                local hash="$(sha1sum - <<<"$PWD" | cut -c-7)"
                local path="''${PWD//[^a-zA-Z0-9]/-}"
                echo "$XDG_CACHE_HOME/direnv/layouts/$hash$path"
            )}"
        }
      '';
    nix-direnv.enable = true;
    config = {warn_timeout = "500h";};
  };

  xdg.configFile."gfold.toml".text = ''
    display_mode = "Classic"
  '';

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
      unzip
      sshfs-fuse
      zip
      scc
      bc
      glow
      gh
      yq
      nmap # also for ncat
      nodePackages.http-server
      nvim
      rename # this is perl-rename
      gfold
      lsof
      kubectl
      kubecolor
      kubectx
      usql
      rsync
      moreutils
      osc
      # bitwarden-cli
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      usbutils
      pciutils
      psmisc
    ];
}
