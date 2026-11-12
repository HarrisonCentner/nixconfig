{
  flake.modules.nixos.paperless =
    { lib, ... }:
    {
      services.paperless = {
        enable = true;
        address = "127.0.0.1";
        # TLS terminated by tailscale serve
        settings.PAPERLESS_PROXY_SSL_HEADER = [
          "HTTP_X_FORWARDED_PROTO"
          "https"
        ];
      };

      systemd.services = lib.mkMerge [
        (lib.genAttrs
          [
            "paperless-consumer"
            "paperless-scheduler"
            "paperless-web"
          ]
          (_: {
            serviceConfig = {
              CPUQuota = "100%";
              MemoryHigh = "6%";
              MemoryMax = "10%";
            };
          })
        )
        {
          # OCR runs here
          paperless-task-queue.serviceConfig = {
            CPUQuota = "200%";
            MemoryHigh = "10%";
            MemoryMax = "15%";
          };
          redis-paperless.serviceConfig = {
            CPUQuota = "50%";
            MemoryHigh = "3%";
            MemoryMax = "5%";
          };
        }
      ];

      tailscaleServices.paperless = 28981;

      ephemeralRoot.persist.directories = [
        "/var/lib/paperless"
      ];
      backup.directories = [
        "/var/lib/paperless"
      ];
    };
}
