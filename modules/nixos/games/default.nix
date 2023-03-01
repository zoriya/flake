{ pkgs, config, lib, ... }: let
cfg = config.games;
in {
  options.games = { enable = lib.mkEnableOption "games"; };
  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server

      environment.systemPackages = with pkgs; [
        steam-run
      ];
    };
  };
}
