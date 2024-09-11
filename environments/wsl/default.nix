{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];

  wsl.enable = true;
  wsl.defaultUser = "zoriya";
  environment.systemPackages = with pkgs; [
    wslu
    wsl-open

    # jetbrains.rider Waiting for https://github.com/NixOS/nixpkgs/pull/284857
    jetbrains.jdk 
  ];

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.zoriya.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGcLP/ZEjnSgkzQMBeLLOWn5uejSr9Gg1h9PJZECVTLm+VDQ7KyI3ORZt+qbfEnsnGL73iwcAqB5Upy9Cdj0182mnrTk2ZViNMeFT7kLBF0yXpiajQTtMjENYj0nbNWpQ5+sJrtJKKYK/tBghW8PyTrJPpVQcrLcf4D66U5DkkJNRDeu4v9SjHKaASUeyia4gRSVV59Ugtrl0lz8sl4yBSL4957zwzdkNR0pVmftaKmUP4KfBvpNcFOOpHcdvzDtEPQs8j0g2l65YOQNNFSMsYQfxt1X4zmEi4unRIlECglaPz12CyoTiM2xmCWa/mS5nm0dR1VbEHFMRtGbbgm9MwedXoxYAfycbu08fqi1AAvg7MQxDNLfWWBIHe7+imGLKrVkqk8B89I409iI4YiOytnUkxKZkxynqVYtEE0bx5J15mniq2vJTw9JD89qSVkvGjZNGuJgh4leIlxPGj4iP8KY3N3Ifaf72PsmmwW4rB5JPDW93RL1DZV8lk3NgyF8M= zoriya@fuhen"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8HuwM/zouKaWAxX8B8IsZXCn9Ax2EDaYctDAjVejD/nqnvHd49AfRSmOreh10qVMqug0jTPltCUkQaoSmeruR8oQ8QsIXP9dGkwtOdcaUqzFUwfr+12xC11x3zOiNUG6LsJ+amcdLIst7WtZ6yMNyxHK1rFqF3JiOkUbUE6f7aqnfLSm5CwRG7qvjm2vb01snr3Vfm04CdQBghMY+3aiyT9Tkv4NOzuyjNJm+3YpIHQIdmLjhsbAnEtALf5Wl0L+1S9aa1NVIGu6dftqMqQfxTV6YbnUzHDj++w1Rpg204t1rxmI7N3+rgIqQB15wF/L0K3qDPPr6E6BaJRtkkAyLq4+jwVzQDww/SifdAbuetFRamXAYBg/PqAGDofgtlDtRLYcbZvJ/y5NlLo9xCPRGd0IiJ98LkMXlKvy28crlKbJf6Sd1U2YlqperlWhmGOxWy1YCm+2hq3MKlL//VobP5LQdvdu1FNwckFdCYVhIk/uaPrCnruy+wTfmdL9UqXM= zoriya@lucca"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnPn6ga4tsJfdyGyft9RnJJmSvlGLn/rJuLsWwFHtxHwdcOolZEAn2zrLqOo1Fty44lrWJ62KLOJ+eZVt4rfREBWd+esttTY2BbhrjvRThKsst1RJdWjFXI3xny7v48mMG8PKjTCkXom2Y/wfLKRpeaNJyCgauUNdDFXuiwiMmIEGXN/WE6LfWBg2XbPWilMLEVm6pwXf3lGtaS0QxhIQ/OIdx5XfUKS6lUfRq9Ki6FbsSQ60ejRtKmjbqY93KNQPUBAJnJHgDDX2+pkrSKiNHBjFH5/HZJTSRdpumaqO0E+HZRSEbR/aKRvshUN0SO/59pvrqb1ARF6CG2X0k0A+jTag0N7SyLwHEJ8J/bl43zm0JWenfAPMuhzQqAv3Vw4i13u8mgHf+ng7ClDo1ms5K7e/XXZV7Asb6orkuslZCO2QR3WgfmbUU03r89aG7Eg58ZeGMP57CoEcMAVah20to4iPm5HPy/Ej0JznFXXjRW4z+/DZDvWhFtsjIkalqQCU= u0_a369@localhost"
  ];


  # Disable it for wls
  environment.persistence."/nix/persist".enable = false;
}
