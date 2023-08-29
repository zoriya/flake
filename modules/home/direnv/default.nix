{
  pkgs,
  config,
  lib,
  ...
}: {
  programs.direnv.enable = true;
  programs.direnv.stdlib = builtins.readFile ./cache.sh;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.config = {warn_timeout = "500h";};

  programs.git.ignores = [".envrc"];
}
