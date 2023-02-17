{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.zsh;

  configThemeNormal = ./p10k.zsh;
  configThemeTTY = ./p10k-tty.zsh;
in {
  options.modules.zsh = {enable = lib.mkEnableOption "zsh";};
  config = lib.mkIf cfg.enable {
    programs.exa.enable = true;

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

        # Misc
        s = "git status";
        op = "xdg-open";
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
          name = "custom";
          src = ./custom.zsh;
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

        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';

      oh-my-zsh = {
        enable = true;
        plugins = [
          "sudo"
          "git"
          "copypath"
          "copyfile"
          "jsontools"
          "command-not-found"
        ];
      };
    };
  };
}
