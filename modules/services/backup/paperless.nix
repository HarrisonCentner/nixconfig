{
  flake.modules.nixos.paperless =
    { ... }:
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

      tailscaleServices.paperless = 28981;

      ephemeralRoot.persist.directories = [
        "/var/lib/paperless"
      ];
      backup.directories = [
        "/var/lib/paperless"
      ];
    };
}
