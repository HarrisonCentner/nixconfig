let
  defaultPort = 2283;
in
{
  flake.modules.nixos.immich =
    { pkgs, ... }:
    {
      config = {
        users.users.immich.extraGroups = [
          "video"
          "render"
        ];
        services.tailscale.serve = {
          enable = true;
          services.immich.endpoints = {
            "tcp:${toString defaultPort}" = "http://localhost:${toString defaultPort}";
          };
        };
        services.immich = {
          enable = true;
          port = defaultPort;
          host = "0.0.0.0";
          mediaLocation = "/var/lib/immich";
          openFirewall = true;
          accelerationDevices = [ "/dev/dri/renderD128" ];
        };

        ephemeralRoot.persist.directories = [
          "/var/lib/immich"
          "/var/lib/postgresql"
        ];
        backup.directories = [
          "/var/lib/immich"
          "/var/lib/postgresql"
        ];
      };
    };
}
