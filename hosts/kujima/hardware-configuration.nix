{lib, ...}: {
  system.stateVersion = "25.11";
  environment.persistence."/nix/persist".enable = false;
  services.automatic-timezoned.enable = lib.mkForce false;
}
