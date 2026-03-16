{
  inputs,
  ...
}:
{
  flake.modules.nixos.microvm-host =
    { pkgs, ... }:
    {
      # Network config for TAP device (QEMU creates the TAP itself)
      systemd.network = {
        enable = true;
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
        externalInterface = "wlp0s20f3";
        internalInterfaces = [ "vm-agent-1" ];
      };

      # virtiofsd for microvm-agent-1
      systemd.services.virtiofsd-microvm-agent-1 = {
        description = "virtiofsd for microvm-agent-1 /nix/store";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          ExecStart = "${pkgs.virtiofsd}/bin/virtiofsd --socket-path=/var/lib/microvm/agent-1/virtiofs-ro-store.sock --shared-dir=/nix/store --sandbox=none --socket-group=users";
        };
      };

      # Shared directory between host and guest via virtiofs
      systemd.tmpfiles.rules = [
        "d /var/lib/microvm/agent-1/shared 0755 root users -"
      ];

      systemd.services.virtiofsd-microvm-agent-1-shared = {
        description = "virtiofsd for microvm-agent-1 shared directory";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          ExecStart = "${pkgs.virtiofsd}/bin/virtiofsd --socket-path=/var/lib/microvm/agent-1/virtiofs-shared.sock --shared-dir=/var/lib/microvm/agent-1/shared --sandbox=none --socket-group=users";
        };
      };

      # Script to copy host Nix DB to the shared directory
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "microvm-sync-nix-db" ''
          set -euo pipefail
          echo "Copying Nix DB to shared directory..."
          cp /nix/var/nix/db/db.sqlite /var/lib/microvm/agent-1/shared/db.sqlite
          echo "Done."
        '')
      ];
    };
}
