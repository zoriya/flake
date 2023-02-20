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
    home.packages = with pkgs; [neovim];

    xdg.configFile."nvim".source = ./.;
  };
}
