{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.ntfy;

  ntfy = pkgs.writeShellScriptBin "ntfy" (builtins.readFile ./tiramisu.sh);
in {
  options.modules.ntfy = {enable = mkEnableOption "ntfy";};

  config = mkIf cfg.enable {
   home.packages = with pkgs; [ ntfy tiramisu ];
  };
}
