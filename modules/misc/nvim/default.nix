{
  pkgs,
  config,
  ...
}: {
  programs.neovim = {
    enable = true;
    withNodeJs = true;
    extraPackages = with pkgs; [
      gcc
      tree-sitter
    ];
  };
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/flake/modules/misc/nvim";

  programs.zsh.shellAliases = {
    n = "nvim";
    vim = "nvim";
    vi = "nvim";
    v = "nvim";
  };

  home.sessionVariables = rec {
    EDITOR = "nvim";
    VISUAL = EDITOR;
  };
}
