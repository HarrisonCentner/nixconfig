{
  flake.modules.nixos.paperless =
    { ... }:
    {
      services = {
        paperless = {
          enable = true;
          address = "127.0.0.1";
        };
        tailscale.serve = {
          enable = true;
          services.paperless.endpoints = {
            "tcp:28981" = "http://127.0.0.1:28981";
          };
        };
      };

      ephemeralRoot.persist.directories = [
        "/var/lib/paperless"
      ];
      backup.directories = [
        "/var/lib/paperless"
      ];
    };
}
