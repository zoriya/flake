{
  pkgs,
  lib,
  ...
}: let
  guesspath =
    pkgs.stdenv.mkDerivation rec {
      name = "guesspath";
      nativeBuildInputs = with pkgs; [makeWrapper];
      propagatedBuildInputs = with pkgs; [
        python3Packages.guessit
        transmission_4
      ];
      dontUnpack = true;
      installPhase = "
     install -Dm755 ${./guesspath.sh} $out/bin/guesspath
     wrapProgram $out/bin/guesspath --prefix PATH : '${lib.makeBinPath propagatedBuildInputs}'
   ";
    };

  smartrss = pkgs.stdenv.mkDerivation rec {
    name = "smartrss";
    nativeBuildInputs = with pkgs; [makeWrapper];
    propagatedBuildInputs = with pkgs; [
      python3Packages.guessit
      curl
      jq
    ];
    dontUnpack = true;
    installPhase = "
        install -Dm755 ${./smartrss.sh} $out/bin/smartrss
        wrapProgram $out/bin/smartrss --prefix PATH : '${lib.makeBinPath propagatedBuildInputs}'
      ";
  };
in {
  # Make it use predictable interface names starting with eth0
  boot.kernelParams = ["net.ifnames=0"];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  programs.mosh.enable = true;

  users.users.zoriya.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGcLP/ZEjnSgkzQMBeLLOWn5uejSr9Gg1h9PJZECVTLm+VDQ7KyI3ORZt+qbfEnsnGL73iwcAqB5Upy9Cdj0182mnrTk2ZViNMeFT7kLBF0yXpiajQTtMjENYj0nbNWpQ5+sJrtJKKYK/tBghW8PyTrJPpVQcrLcf4D66U5DkkJNRDeu4v9SjHKaASUeyia4gRSVV59Ugtrl0lz8sl4yBSL4957zwzdkNR0pVmftaKmUP4KfBvpNcFOOpHcdvzDtEPQs8j0g2l65YOQNNFSMsYQfxt1X4zmEi4unRIlECglaPz12CyoTiM2xmCWa/mS5nm0dR1VbEHFMRtGbbgm9MwedXoxYAfycbu08fqi1AAvg7MQxDNLfWWBIHe7+imGLKrVkqk8B89I409iI4YiOytnUkxKZkxynqVYtEE0bx5J15mniq2vJTw9JD89qSVkvGjZNGuJgh4leIlxPGj4iP8KY3N3Ifaf72PsmmwW4rB5JPDW93RL1DZV8lk3NgyF8M= zoriya@fuhen"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8HuwM/zouKaWAxX8B8IsZXCn9Ax2EDaYctDAjVejD/nqnvHd49AfRSmOreh10qVMqug0jTPltCUkQaoSmeruR8oQ8QsIXP9dGkwtOdcaUqzFUwfr+12xC11x3zOiNUG6LsJ+amcdLIst7WtZ6yMNyxHK1rFqF3JiOkUbUE6f7aqnfLSm5CwRG7qvjm2vb01snr3Vfm04CdQBghMY+3aiyT9Tkv4NOzuyjNJm+3YpIHQIdmLjhsbAnEtALf5Wl0L+1S9aa1NVIGu6dftqMqQfxTV6YbnUzHDj++w1Rpg204t1rxmI7N3+rgIqQB15wF/L0K3qDPPr6E6BaJRtkkAyLq4+jwVzQDww/SifdAbuetFRamXAYBg/PqAGDofgtlDtRLYcbZvJ/y5NlLo9xCPRGd0IiJ98LkMXlKvy28crlKbJf6Sd1U2YlqperlWhmGOxWy1YCm+2hq3MKlL//VobP5LQdvdu1FNwckFdCYVhIk/uaPrCnruy+wTfmdL9UqXM= zoriya@lucca"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnPn6ga4tsJfdyGyft9RnJJmSvlGLn/rJuLsWwFHtxHwdcOolZEAn2zrLqOo1Fty44lrWJ62KLOJ+eZVt4rfREBWd+esttTY2BbhrjvRThKsst1RJdWjFXI3xny7v48mMG8PKjTCkXom2Y/wfLKRpeaNJyCgauUNdDFXuiwiMmIEGXN/WE6LfWBg2XbPWilMLEVm6pwXf3lGtaS0QxhIQ/OIdx5XfUKS6lUfRq9Ki6FbsSQ60ejRtKmjbqY93KNQPUBAJnJHgDDX2+pkrSKiNHBjFH5/HZJTSRdpumaqO0E+HZRSEbR/aKRvshUN0SO/59pvrqb1ARF6CG2X0k0A+jTag0N7SyLwHEJ8J/bl43zm0JWenfAPMuhzQqAv3Vw4i13u8mgHf+ng7ClDo1ms5K7e/XXZV7Asb6orkuslZCO2QR3WgfmbUU03r89aG7Eg58ZeGMP57CoEcMAVah20to4iPm5HPy/Ej0JznFXXjRW4z+/DZDvWhFtsjIkalqQCU= u0_a369@localhost"
  ];

  services.fail2ban = {
    enable = true;
    bantime = "-1";
    ignoreIP = [
      "192.168.0.0/16"
    ];
    maxretry = 5;
  };

  # virtualisation.oci-containers.containers."watchtower" = {
  #   autoStart = true;
  #   image = "containrrr/watchtower";
  #   volumes = [
  #     "/var/run/docker.sock:/var/run/docker.sock"
  #   ];
  #   environment = {
  #     WATCHTOWER_CLEANUP = "true";
  #     WATCHTOWER_POLL_INTERVAL = "86400";
  #   };
  # };

  networking.firewall.allowedTCPPorts = [80 443];
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."kyoo.sdg.moe" = {
      enableACME = true;
      forceSSL = true;

      locations."/robots.txt" = {
        extraConfig = ''
          rewrite ^/(.*)  $1;
          return 200 "User-agent: *\nDisallow: /";
        '';
      };

      locations."/" = {
        proxyPass = "http://localhost:8901";
        proxyWebsockets = true;
        extraConfig = "proxy_pass_header Authorization;";
      };
    };

    virtualHosts."flood.sdg.moe" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3000";
        proxyWebsockets = true;
        extraConfig = "proxy_pass_header Authorization;";
      };
    };

    virtualHosts."reader.sdg.moe" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:2345";
        proxyWebsockets = true;
        extraConfig = "proxy_pass_header Authorization;";
      };
    };

    virtualHosts."proxy.sdg.moe" = {
      locations."/" = {
        proxyPass = "http://localhost:5000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_pass_header Authorization;
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "zoe.roux@zoriya.dev";
  };

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    # Make downloaded items readable/writtable by users
    group = "users";
    settings = {
      incomplete-dir-enabled = false;
      download-dir = "/mnt/kyoo/downloads";
      download-queue-enabled = false;
      rename-partial-files = false;
      trash-can-enabled = false;
      ratio-limit-enabled = true;
      ratio-limit = 1;
      script-torrent-added-enabled = true;
      script-torrent-added-filename = "${guesspath}/bin/guesspath";
    };
  };
  # Also allows transmission to reach thoses files
  systemd.services.transmission.serviceConfig.BindPaths = ["/mnt/kyoo/shows"];
  systemd.services.flood = {
    enable = true;
    wantedBy = ["multi-user.target"];
    after = ["transmission.service"];
    requires = ["transmission.service"];
    path = with pkgs; [mediainfo smartrss];
    serviceConfig = {
      ExecStart = "${pkgs.flood}/bin/flood --rundir=/var/lib/flood --trurl=http://127.0.0.1:9091/transmission/rpc --truser '' --trpass ''";
      User = "transmission";
      Restart = "on-failure";
    };
  };
}
