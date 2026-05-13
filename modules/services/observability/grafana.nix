{
  flake.modules.nixos.grafana =
    {
      services.grafana = {
        enable = true;
        openFirewall = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = 3000;
            enable_gzip = true;
          };
          # prevent Grafana from phoning home
          analytics.reporting_enabled = false;
        };
      };
    };
}
