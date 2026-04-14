{
  flake.modules.nixos.paperless =
    { ... }:
    {
      services = {
        paperless = {
          enable = true;
          address = "0.0.0.0";
        };
        tailscale.serve = {
          enable = true;
          services.paperless.endpoints = {
            "tcp:28981" = "http://localhost:28981";
          };
        };
      };

      ephemeralRoot.persist.directories = [
        "/var/lib/paperless"
      ];
    };
}
