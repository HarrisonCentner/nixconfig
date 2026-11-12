{ mkOpSecret, ... }:
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
              accel = "vaapi";
              preset = "medium";
              targetResolution = "1080";
            };
            image.fullsize.enabled = true;
            job = {
              thumbnailGeneration.concurrency = 2;
              smartSearch.concurrency = 1;
              faceDetection.concurrency = 1;
            };
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

      # bulk imports must not starve tailscaled/sshd or thrash swap
      systemd.services = {
        immich-server.serviceConfig = {
          CPUQuota = "300%";
          MemoryHigh = "25%";
          MemoryMax = "35%";
          MemorySwapMax = "2G";
        };
        immich-machine-learning.serviceConfig = {
          CPUQuota = "200%";
          MemoryHigh = "20%";
          MemoryMax = "30%";
          MemorySwapMax = "2G";
        };
        postgresql.serviceConfig = {
          CPUQuota = "200%";
          MemoryHigh = "20%";
          MemoryMax = "30%";
        };
        redis-immich.serviceConfig = {
          CPUQuota = "50%";
          MemoryHigh = "3%";
          MemoryMax = "5%";
        };
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
