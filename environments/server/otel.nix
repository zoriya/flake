{pkgs, ...}: {
  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    configFile = ./otelcol.yaml;
  };

  services.mimir = {
    enable = true;
    configuration = {
      multitenancy_enabled = false;
      server = {
        http_listen_port = 1880;
        grpc_listen_port = 9095;
      };
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
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
        ring = {
          kvstore = {
            store = "inmemory";
          };
        };
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
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "mimir";
          type = "prometheus";
          url = "http://localhost:1880/prometheus";
          isDefault = false;
          jsonData = {
            prometheusType = "Mimir";
          };
        }
        {
          name = "loki";
          type = "loki";
          url = "http://localhost:1881";
          isDefault = true;
        }
        {
          name = "tempo";
          type = "tempo";
          url = "localhost:1882";
          isDefault = false;
        }
      ];
    };
  };
}
