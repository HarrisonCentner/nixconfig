let
  port = 8428;
  nodeExporterPort = 9100;
in
{
  flake.modules.nixos.victoriametrics =
    { hostConfig, lib, ... }:
    {
      services.victoriametrics = {
        enable = true;
        listenAddress = "127.0.0.1:${toString port}";
        retentionPeriod = "1y";
        prometheusConfig.scrape_configs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString nodeExporterPort}" ];
                labels.instance = hostConfig.name;
              }
            ];
          }
        ];
      };

      # static user: DynamicUser's /var/lib/private doesn't survive impermanence binds
      systemd.services.victoriametrics.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "victoriametrics";
        Group = "victoriametrics";
      };
      users = {
        users.victoriametrics = {
          isSystemUser = true;
          group = "victoriametrics";
        };
        groups.victoriametrics = { };
      };

      tailscaleServices.victoriametrics = port;

      ephemeralRoot.persist.directories = [ "/var/lib/victoriametrics" ];
    };

  flake.modules.nixos.node-exporter =
    { pkgs, ... }:
    {
      services.prometheus.exporters.node = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = nodeExporterPort;
      };

      # RAPL energy counters are root-only since PLATYPUS
      systemd.services.prometheus-node-exporter.serviceConfig.ExecStartPre =
        "+${pkgs.writeShellScript "rapl-node-exporter-access" ''
          for f in /sys/class/powercap/*/energy_uj; do
            [ -e "$f" ] || continue
            chgrp node-exporter "$f"
            chmod 0440 "$f"
          done
        ''}";
    };
}
