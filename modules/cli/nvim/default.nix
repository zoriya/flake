{
  pkgs,
  config,
  neovim-nightly,
  ...
}: {
  programs.neovim = {
    enable = true;
    withNodeJs = true;
    package = neovim-nightly.packages.${pkgs.system}.default;
    extraPackages = with pkgs; [
      gcc
      tree-sitter
      # Give access to gdbus for color-scheme detection (vim-lumen).
      glib
    ];
  };
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/flake/modules/cli/nvim";

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
