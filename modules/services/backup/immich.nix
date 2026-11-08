let
  defaultPort = 2283;
in
{
  flake.modules.nixos.immich = {
    config = {
      users.users.immich.extraGroups = [
        "video"
        "render"
      ];
      tailscaleServices.immich = defaultPort;
      services.immich = {
        enable = true;
        port = defaultPort;
        host = "127.0.0.1";
        mediaLocation = "/var/lib/immich";
        accelerationDevices = [ "/dev/dri/renderD128" ];
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
  };
}
