{
  inputs,
  ...
}:
{
  flake.modules.nixos.microvm-guest =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.microvm.nixosModules.microvm ];

      nix = {
        optimise.automatic = lib.mkForce false;
        channel.enable = false;
        settings = {
          accept-flake-config = true;
          substituters = [
            "https://devenv.cachix.org"
          ];
          trusted-public-keys = [
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
        };
      };
      boot.nixStoreMountOpts = [
        "nodev"
        "nosuid"
      ];
      environment.systemPackages = [
        pkgs.cachix
        pkgs.dconf
      ];
      programs.dconf.enable = true;
      networking.firewall.enable = false;
      zramSwap.enable = true;

      microvm = {
        hypervisor = "qemu";
        qemu.serialConsole = true;
        mem = 8192;
        vcpu = 6;
        graphics.enable = true;

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
          {
            tag = "host-shared";
            source = "/var/lib/microvm/agent-1/shared";
            mountPoint = "/mnt/host-shared";
            proto = "virtiofs";
            socket = "/var/lib/microvm/agent-1/virtiofs-shared.sock";
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
          networkConfig = {
            Address = "10.0.100.2/30";
            DNS = [ "1.1.1.1" ];
          };
          routes = [ { Gateway = "10.0.100.1"; } ];
        };
      };

      # Set up dm-crypt for rw-store in initrd, before the overlay is mounted
      boot.initrd = {
        kernelModules = [
          "dm-mod"
          "dm-crypt"
          "algif_skcipher"
          "aes"
          "xts"
        ];
        systemd = {
          enable = true;
          extraBin = {
            cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
            mkfs-ext4 = "${pkgs.e2fsprogs}/bin/mkfs.ext4";
          };
          services.ephemeral-crypt = {
            description = "Set up dm-crypt with ephemeral keys";
            wantedBy = [ "initrd.target" ];
            before = [ "sysroot-nix-.rw\\x2dstore.mount" ];
            after = [ "systemd-modules-load.service" ];
            unitConfig.DefaultDependencies = false;
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              setup_volume() {
                local dev="$1" name="$2"
                dd if=/dev/random of=/run/ephemeral.key bs=32 count=1
                cryptsetup open --type plain --key-file /run/ephemeral.key "$dev" "$name"
                mkfs.ext4 -L "$name" "/dev/mapper/$name"
                rm /run/ephemeral.key
              }

              setup_volume /dev/vda crypt-rw-store
              setup_volume /dev/vdb crypt-data
            '';
          };
        };
      };

      # Mount the dm-crypt device as the writable store overlay
      fileSystems."/nix/.rw-store" = {
        device = "/dev/mapper/crypt-rw-store";
        fsType = "ext4";
        neededForBoot = true;
      };

      fileSystems."/var/lib/microvm/agent-1" = {
        device = "/dev/mapper/crypt-data";
        fsType = "ext4";
        neededForBoot = true;
      };

      fileSystems."/home" = {
        device = "/var/lib/microvm/agent-1/home";
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/var/lib/microvm/agent-1" ];
      };

      # Copy host Nix DB then re-register guest closure paths on top.
      # microvm.nix's postBootCommands registers the guest closure first,
      # then this service overwrites with the host DB and re-registers.
      systemd = {
        services.nix-load-host-db = {
          description = "Load host Nix DB into guest";
          wantedBy = [ "multi-user.target" ];
          before = [
            "nix-daemon.service"
            "home-manager-microvm\\x2dagent.service"
          ];
          after = [ "nix-store.mount" ];
          requires = [ "nix-store.mount" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            if [ -f /mnt/host-shared/db.sqlite ]; then
              cp /mnt/host-shared/db.sqlite /nix/var/nix/db/db.sqlite
            fi

            # Re-register guest closure paths on top of the host DB
            if [[ "$(cat /proc/cmdline)" =~ regInfo=([^ ]*) ]]; then
              ${pkgs.nix}/bin/nix-store --load-db < "''${BASH_REMATCH[1]}"
            fi
          '';
        };

        # Create home directory on first mount
        tmpfiles.rules = [
          "d /var/lib/microvm/agent-1/home/microvm-agent 0700 microvm-agent users -"
        ];
      };
    };
}
