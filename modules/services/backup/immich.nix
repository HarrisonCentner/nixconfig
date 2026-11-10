let
  defaultPort = 2283;
  apiMetricsPort = 8081;
  microservicesMetricsPort = 8082;
in
{
  flake.modules.nixos.immich =
    { hostConfig, ... }:
    {
      users.users.immich.extraGroups = [
        "video"
        "render"
      ];
      tailscaleServices.immich = defaultPort;
      services = {
        immich = {
          enable = true;
          port = defaultPort;
          host = "127.0.0.1";
          mediaLocation = "/var/lib/immich";
          accelerationDevices = [ "/dev/dri/renderD128" ];
          environment = {
            IMMICH_TELEMETRY_INCLUDE = "api,job";
            IMMICH_API_METRICS_PORT = toString apiMetricsPort;
            IMMICH_MICROSERVICES_METRICS_PORT = toString microservicesMetricsPort;
          };
          settings = {
            newVersionCheck.enabled = false;
            ffmpeg = {
              accel = "qsv";
              preset = "medium";
              targetResolution = "1080";
            };
            image.fullsize.enabled = true;
            machineLearning.clip.modelName = "ViT-B-16-SigLIP2__webli";
            backup.database = {
              cronExpression = "0 13 * * *";
              keepLastAmount = 4;
            };
          };
        };
        victoriametrics.prometheusConfig.scrape_configs = [
          {
            job_name = "immich";
            static_configs = [
              {
                targets = [
                  "127.0.0.1:${toString apiMetricsPort}"
                  "127.0.0.1:${toString microservicesMetricsPort}"
                ];
                labels.instance = hostConfig.name;
              }
            ];
          }
        ];
      };

      ephemeralRoot.persist.directories = [ "/var/lib/immich" ];

      backup = {
        directories = [ "/var/lib/immich" ];
        exclude = [
          "/var/lib/immich/thumbs"
          "/var/lib/immich/encoded-video"
        ];
      };
    };
}
