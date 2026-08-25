{
  lanzaboote,
  lib,
  ...
}: {
  imports = [lanzaboote.nixosModules.lanzaboote];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.systemd-boot.editor = false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
    autoEnrollKeys.enable = true;
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/sbctl";
      mode = "0700";
    }
  ];
}
