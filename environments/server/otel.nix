{pkgs, ...}: {
  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    configFile = ./otelcol.yaml;
  };

  services.mimir = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 1880;
        grpc_listen_port = 9095;
      };
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 1881;
        grpc_listen_port = 9096;
      };
      storage_config = {
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };
      common = {
        path_prefix = "/var/lib/loki";
      };
      schema_config = {
        configs = [
          {
            from = "2020-05-15";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };
    };
  };

  services.tempo = {
    enable = true;
    settings = {
      server = {
        http_listen_port = 1882;
        grpc_listen_port = 9097;
      };
      storage = {
        trace = {
          backend = "local";
          local = {
            path = "/var/lib/tempo";
          };
          wal = {
            path = "/var/lib/tempo/wal";
          };
        };
      };
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 1892;
        domain = "grafana.sdg.moe";
      };
    };
  };
}
