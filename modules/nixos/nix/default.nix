{
  lib,
  config,
  ...
}: let
  cfg = config.nixconf;
in {
  options.nixconf = {enable = lib.mkEnableOption "nix";};
  config = lib.mkIf cfg.enable {
    nix = {
      settings.auto-optimise-store = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
    };
    nixpkgs.config.allowUnfree = true;
  };
}
