{ghostty, system, ...}: let
  pkg = ghostty.packages.${system}.default;
in {
  xdg.configFile."ghostty/config".source = ./ghostty.config;

  programs.zsh.initExtra = ''
    # load ghostty integration (responsible for OSC 133 aka sementic prompts)
    if [[ $TERM != "dumb" ]]; then
      autoload -Uz -- ${pkg}/share/ghostty/shell-integration/zsh/ghostty-integration
      ghostty-integration
      unfunction ghostty-integration
    fi
  '';

  home.packages = [
    pkg
  ];
}
