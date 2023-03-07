{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.nvim;
in {
  options.modules.nvim = {enable = lib.mkEnableOption "nvim";};

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [neovim-nightly];

    xdg.configFile."nvim/lua".source = ./lua;
    xdg.configFile."nvim/lazy-lock.json".source = ./lazy-lock.json;
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
  };
}
