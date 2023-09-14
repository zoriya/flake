{
  # Make it use predictable interface names starting with eth0
  boot.kernelParams = ["net.ifnames=0"];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.zoriya.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGcLP/ZEjnSgkzQMBeLLOWn5uejSr9Gg1h9PJZECVTLm+VDQ7KyI3ORZt+qbfEnsnGL73iwcAqB5Upy9Cdj0182mnrTk2ZViNMeFT7kLBF0yXpiajQTtMjENYj0nbNWpQ5+sJrtJKKYK/tBghW8PyTrJPpVQcrLcf4D66U5DkkJNRDeu4v9SjHKaASUeyia4gRSVV59Ugtrl0lz8sl4yBSL4957zwzdkNR0pVmftaKmUP4KfBvpNcFOOpHcdvzDtEPQs8j0g2l65YOQNNFSMsYQfxt1X4zmEi4unRIlECglaPz12CyoTiM2xmCWa/mS5nm0dR1VbEHFMRtGbbgm9MwedXoxYAfycbu08fqi1AAvg7MQxDNLfWWBIHe7+imGLKrVkqk8B89I409iI4YiOytnUkxKZkxynqVYtEE0bx5J15mniq2vJTw9JD89qSVkvGjZNGuJgh4leIlxPGj4iP8KY3N3Ifaf72PsmmwW4rB5JPDW93RL1DZV8lk3NgyF8M= zoriya@fuhen"
  ];

  services.fail2ban = {
    enable = true;
    bantime = "-1";
  };

  virtualisation.oci-containers.containers."watchtower" = {
    autoStart = true;
    image = "containrrr/watchtower";
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
    ]; 
  };
}
