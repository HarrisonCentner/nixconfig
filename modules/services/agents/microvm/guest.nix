{
  inputs,
  ...
}:
{
  flake.modules.nixos.microvm-guest =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.microvm.nixosModules.microvm ];

      nix.optimise.automatic = lib.mkForce false;

      microvm = {
        hypervisor = "qemu";
        qemu.serialConsole = true;

        interfaces = [
          {
            type = "tap";
            id = "vm-agent-1";
            mac = "02:00:00:00:00:01";
          }
        ];

        shares = [
          {
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            proto = "virtiofs";
            socket = "/var/lib/microvm/agent-1/virtiofs-ro-store.sock";
          }
        ];

        writableStoreOverlay = "/nix/.rw-store";
        volumes = [
          {
            image = "/var/lib/microvm/agent-1/nix-store-overlay.img";
            mountPoint = null;
            size = 8192; # 8GB
          }
          {
            image = "/var/lib/microvm/agent-1/data.img";
            mountPoint = null;
            size = 16384; # 16 GB
          }
        ];
      };

      systemd.network = {
        enable = true;
        networks."20-eth0" = {
          matchConfig.MACAddress = "02:00:00:00:00:01";
          networkConfig.Address = "10.0.100.2/30";
          routes = [{ Gateway = "10.0.100.1"; }];
        };
      };

      systemd.services.ephemeral-crypt = {
        description = "Set up dm-crypt with ephemeral key for encrypted volumes";
        wantedBy = [ "local-fs.target" ];
        before = [ "local-fs.target" ];
        after = [ "systemd-modules-load.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = with pkgs; [ cryptsetup util-linux e2fsprogs ];
        script = ''
          dd if=/dev/random of=/run/ephemeral.key bs=32 count=1

          cryptsetup open --type plain --key-file /run/ephemeral.key /dev/vdb crypt-rw-store
          mkfs.ext4 -L rw-store /dev/mapper/crypt-rw-store
          mkdir -p /nix/.rw-store
          mount /dev/mapper/crypt-rw-store /nix/.rw-store

          cryptsetup open --type plain --key-file /run/ephemeral.key /dev/vdc crypt-data
          mkfs.ext4 -L data /dev/mapper/crypt-data
          mkdir -p /var/lib/microvm/agent-1
          mount /dev/mapper/crypt-data /var/lib/microvm/agent-1

          rm /run/ephemeral.key
        '';
      };
    };
}
