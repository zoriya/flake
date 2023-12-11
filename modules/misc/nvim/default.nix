{pkgs, config, ...}: {
  home.packages = with pkgs; [
    # neovim
    neovim-nightly
  ];
  xdg.configFile."nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/flake/modules/misc/nvim/lua";
  xdg.configFile."nvim/after".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/flake/modules/misc/nvim/after";
  xdg.configFile."nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/flake/modules/misc/nvim/lazy-lock.json";
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
