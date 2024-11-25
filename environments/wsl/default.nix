{
  services.openssh = {
    enable = true;
    ports = [1022];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Disable it for wls
  environment.persistence."/nix/persist".enable = false;
}
