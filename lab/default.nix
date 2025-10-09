{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homelab.services = {
    enable = lib.mkEnableOption "Settings and services for the homelab";
  };

  config = lib.mkIf config.homelab.services.enable {
    networking.firewall.enable = false;
    networking.firewall.allowedTCPPorts = [
      80
      443 
      2283 # immich
      53 # blocky
    ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };

  imports = [
    ./services/immich/default.nix
    ./services/blocky/default.nix
  ];
}
