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
      };
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 1881;
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
            schema= "v13";
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
