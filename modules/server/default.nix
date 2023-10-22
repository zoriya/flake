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

  users.users.zoriya.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGcLP/ZEjnSgkzQMBeLLOWn5uejSr9Gg1h9PJZECVTLm+VDQ7KyI3ORZt+qbfEnsnGL73iwcAqB5Upy9Cdj0182mnrTk2ZViNMeFT7kLBF0yXpiajQTtMjENYj0nbNWpQ5+sJrtJKKYK/tBghW8PyTrJPpVQcrLcf4D66U5DkkJNRDeu4v9SjHKaASUeyia4gRSVV59Ugtrl0lz8sl4yBSL4957zwzdkNR0pVmftaKmUP4KfBvpNcFOOpHcdvzDtEPQs8j0g2l65YOQNNFSMsYQfxt1X4zmEi4unRIlECglaPz12CyoTiM2xmCWa/mS5nm0dR1VbEHFMRtGbbgm9MwedXoxYAfycbu08fqi1AAvg7MQxDNLfWWBIHe7+imGLKrVkqk8B89I409iI4YiOytnUkxKZkxynqVYtEE0bx5J15mniq2vJTw9JD89qSVkvGjZNGuJgh4leIlxPGj4iP8KY3N3Ifaf72PsmmwW4rB5JPDW93RL1DZV8lk3NgyF8M= zoriya@fuhen"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0Rkye1t+iS00HBb4qgRkIAmZVGwFDJncckmMH6YKhlsj6Gw601Enn0x2GvG1FTCSH2ERGP4MPK9+ZsIcJf2MAmLsa8mR6HLBoN9ipqZQYBIrqWkO4tW7EJemAwgCTxGdOOEfE25ke7+ZvxlkmkBIVTRR6S8BqM+ARifbfw8DhSuUlBDQB3KzSVo/7Qhbvwpuwfn9Ws3pYhPG9yPfSECDGZB9Mf1XRt46/CA81Cqqp0izwo3Zwzd+LW8ZcBRwiCvWmDvKJaBHyUo5FRIGKGvZpfOTXOGeNFC7W7Ja3m/vQikrTboAMnfMhSxi3brZzCjQh57MxwglCHW7UqT95PSvtKVioM5662Mav8kUMOXZpkEWq/NDrWUOqbNkDXga8Lbi6fiybASwJ+Gmq19AFc8mW3pUavAFEuZ/uRebbEMp+V6tRwY2Le05oY1QwcRNLG2ln9HMHDDPaycArTuZC+YJlQv5bNzht3RAsNyFZ4Zx7yvzE38uFhrYHEIcJFXNprUc= u0_a266@localhost"
  ];

  services.fail2ban = {
    enable = true;
    bantime = "-1";
    ignoreIP = [
      "192.168.0.0/16"
    ];
    maxretry = 5;
  };

  virtualisation.oci-containers.containers."watchtower" = {
    autoStart = true;
    image = "containrrr/watchtower";
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
    ];
    environment = {
      WATCHTOWER_CLEANUP = "true";
      WATCHTOWER_POLL_INTERVAL = "86400";
    };
  };

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
