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
      services.immich = {
        enable = true;
        port = defaultPort;
        host = "0.0.0.0";
        mediaLocation = "/var/lib/immich";
        openFirewall = true;
      };
      networking.firewall.allowedTCPPorts = [ defaultPort ];
      networking.firewall.allowedUDPPorts = [ defaultPort ];
    };
  };
}

