{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.direnv;
in {
  options.modules.direnv = {enable = lib.mkEnableOption "direnv";};
  config = lib.mkIf cfg.enable {
    programs.direnv.enable = true;
    programs.direnv.stdlib = builtins.readFile ./cache.sh;
    programs.direnv.nix-direnv.enable = true;
    programs.direnv.config = {warn_timeout = "500h";};

    programs.git.ignores = [".envrc"];
  };
}
