{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.apps;
in {
  options.modules.apps = {enable = mkEnableOption "apps";};

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
      kitty
      google-chrome
      firefox
    ];
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "kitty";
      BROWSER = "google-chrome-stable";
    };
  };
}
