{
  pkgs,
  zshpkgs,
  config,
  lib,
  jq,
  ...
}: let
  cfg = config.modules.zsh;

  configThemeNormal = ./p10k.zsh;
  configThemeTTY = ./p10k-tty.zsh;
in {
  options.modules.zsh = {enable = lib.mkEnableOption "zsh";};
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      exa
      bat
      viu
      htop
      tldr
      jq
      fd
      ripgrep
      psmisc
      atuin
      fzf
      nix-your-shell
    ];

    programs.zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      dotDir = ".config/zsh";
      shellAliases = {
        # ls/exa stuff
        l = "ls -l";
        ll = "ls -l";
        la = "ls -la";
        lla = "ls -la";
        lc = "l --color";
        exa = "exa --group";
        lg = "exa -l --git-ignore";
        ls = "exa";
        lt = "exa --tree";
        tree = "exa --tree";

        # git stuff
        gl = "git log";
        gu = "git pull";

        # Misc
        s = "git status";
        op = "xdg-open";
        wp = "~/.config/hypr/wallpaper.sh";
        py = "nix-shell -p python3";
        jctl = "sudo journalctl -n 1000 -fu";
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "jq";
          src = jq;
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
  };
}