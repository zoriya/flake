{
  pkgs,
  lib,
  ...
}: let
  guesspath = pkgs.stdenv.mkDerivation rec {
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
  imports = [
    ./otel.nix
  ];

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

  services.fail2ban = {
    enable = true;
    bantime = "5w";
    ignoreIP = [
      "192.168.0.0/16"
    ];
    maxretry = 5;
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

    virtualHosts."git.sdg.moe" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:4789";
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
      enableACME = true;
      addSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:5000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_pass_header Authorization;
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };

    virtualHosts."otel.sdg.moe" = {
      enableACME = true;
      addSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:4318";
        proxyWebsockets = true;
        extraConfig = "proxy_pass_header Authorization;";
      };
    };
    # virtualHosts."otel-grpc.sdg.moe" = {
    #   enableACME = true;
    #   addSSL = true;
    #   locations."/" = {
    #     grpcPass = "http://localhost:4317";
    #   };
    # };

    virtualHosts."grafana.sdg.moe" = {
      enableACME = true;
      addSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:1892";
        proxyWebsockets = true;
        recommendedProxySettings = true;
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
    # Make downloaded items readable/writable by users
    group = "users";
    settings = {
      umask = "002";
      incomplete-dir-enabled = false;
      download-dir = "/mnt/kyoo/downloads";
      download-queue-enabled = false;
      rename-partial-files = false;
      trash-can-enabled = false;
      script-torrent-added-enabled = true;
      script-torrent-added-filename = "${guesspath}/bin/guesspath";
    };
  };
  # Also allows transmission to reach theses files
  systemd.services.transmission.serviceConfig.BindPaths = [
    "/mnt/kyoo/downloads"
    "/mnt/kyoo/shows"
    "/mnt/kyoo/lives"
    "/mnt/kyoo/manga"
  ];
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

  services.gitea = {
    enable = true;
    settings.server = rec {
      DOMAIN = "sdg.moe";
      ROOT_URL = "https://git.${DOMAIN}/";
      HTTP_PORT = 4789;
      DISABLE_SSH = true;
    };
  };
}
