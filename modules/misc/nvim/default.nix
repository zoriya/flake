{pkgs, ...}: {
  home.packages = with pkgs; [
    neovim
    #neovim-nightly
  ];
  xdg.configFile."nvim/lua".source = ./lua;
  xdg.configFile."nvim/init.lua".text = ''
    -- Nix
    vim.env.CC = "${pkgs.gcc}/bin/gcc"

    ${builtins.readFile ./init.lua}
  '';

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
