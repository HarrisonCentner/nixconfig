{
  inputs,
  ...
}:
{
  flake.modules.nixos.microvm-host =
    { pkgs, ... }:
    {
      # TAP device for microvm-agent-1
      systemd.network = {
        enable = true;
        netdevs."10-vm-agent-1" = {
          netdevConfig = {
            Name = "vm-agent-1";
            Kind = "tap";
          };
        };
        networks."10-vm-agent-1" = {
          matchConfig.Name = "vm-agent-1";
          networkConfig = {
            Address = "10.0.100.1/30";
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          };
        };
      };

      # NAT for VM internet access
      networking.nat = {
        enable = true;
        internalInterfaces = [ "vm-agent-1" ];
      };

      # virtiofsd for microvm-agent-1
      systemd.services.virtiofsd-microvm-agent-1 = {
        description = "virtiofsd for microvm-agent-1 /nix/store";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          ExecStart = "${pkgs.virtiofsd}/bin/virtiofsd --socket-path=/var/lib/microvm/agent-1/virtiofs-ro-store.sock --shared-dir=/nix/store --sandbox=none --socket-group=users";
        };
      };
    };
}
