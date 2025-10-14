{
  config,
  lib,
  pkgs,
  simple-nixos-mailserver,
  ...
}:
{
  options.homelab.services = {
    enable = lib.mkEnableOption "Settings and services for the homelab";
  };

  config = lib.mkIf config.homelab.services.enable {
    networking.firewall.enable = true;
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
    ./services/blog/default.nix
    # In the future maybe try Maddy.
    # For now it's not worth it for me to run my own mailserver
    # I'm signing up for indefinite maintenance
    # simple-nixos-mailserver.nixosModule (import ./services/mail/default.nix)
  ];
}
