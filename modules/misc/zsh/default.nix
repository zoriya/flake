{
  pkgs,
  ...
}: let
  configThemeNormal = ./p10k.zsh;
  configThemeTTY = ./p10k-tty.zsh;
in {
  home.packages = with pkgs; [
    eza
    viu
    htop-vim
    tldr
    jq
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
    nodePackages.http-server
    nodePackages.live-server
  ];

  programs.atuin = {
    enable = true;
    settings = {
      update_check = false;
    };
  };

  programs.bat = {
    enable = true;
    config.theme = "base16";
  };

  programs.less = {
    enable = true;
    # keys = ''
    #   \e quit
    # '';
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    enableAutosuggestions = true;
    enableCompletion = true;
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
      gl = "git log";
      gu = "git pull";
      gcam = "git commit --amend";
      gcamn = "git commit --amend --no-edit";

      # Misc
      s = "git status";
      dc = "docker-compose";
      dcd = "docker-compose -f docker-compose.dev.yml";
      op = "xdg-open";
      py = "python3 2> /dev/null || nix-shell -p python3 --command python3";
      jctl = "sudo journalctl -n 1000 -fu";
      where = "where -s"; # Follow symlinks
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "bd";
        src = pkgs.zsh-bd;
        file = "share/zsh-bd/bd.zsh";
      }
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
    ];
    initExtra = ''
      # The powerlevel theme I'm using is distgusting in TTY, let's default
      # to something else
      # See https://github.com/romkatv/powerlevel10k/issues/325
      # Instead of sourcing this file you could also add another plugin as
      # this, and it will automatically load the file for us
      # (but this way it is not possible to conditionally load a file)
      # {
      #   name = "powerlevel10k-config";
      #   src = lib.cleanSource ./p10k-config;
      #   file = "p10k.zsh";
      # }
      if zmodload zsh/terminfo && (( terminfo[colors] >= 256 )); then
        [[ ! -f ${configThemeNormal} ]] || source ${configThemeNormal}
      else
        [[ ! -f ${configThemeTTY} ]] || source ${configThemeTTY}
      fi

      ${builtins.readFile ./init.zsh}
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "sudo"
        "git"
        "copypath"
        "copyfile"
        "command-not-found"
      ];
    };
  };
}
