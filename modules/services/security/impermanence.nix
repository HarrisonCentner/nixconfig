{
  # Custom options that any module can write to unconditionally.
  # Only mapped to real impermanence config when a host imports ephemeral-root.
  flake.modules.nixos.base =
    { lib, config, ... }:
    {
      options.ephemeralRoot = {
        enable = lib.mkEnableOption "ephemeral root filesystem with impermanence";
        persist = {
          directories = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          files = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
      };

      config = lib.mkIf config.ephemeralRoot.enable {
        environment.persistence."/persist" = {
          hideMounts = true;
          inherit (config.ephemeralRoot.persist) directories files;
        };
      };
    };

  # Home is its own btrfs subvolume that survives the root rollback, so no
  # bind-persistence is wired. Options kept so modules may still declare intent.
  flake.modules.homeManager.base =
    { lib, ... }:
    {
      options.ephemeralRoot.persist = {
        directories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        files = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };
    };

  # The opt-in module — importing this enables everything.
  flake.modules.nixos.ephemeral-root = {
    ephemeralRoot = {
      enable = true;
      persist = {
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd"
        ];
        files = [
          "/etc/machine-id"
          "/etc/shadow"
          "/etc/passwd"
          "/etc/group"
          "/etc/gshadow"
        ];
      };
    };

    boot.initrd.systemd.services.rollback = {
      description = "Rollback btrfs root subvolume to blank";
      wantedBy = [ "initrd.target" ];
      after = [
        "systemd-cryptsetup@crypted.service"
        "dev-mapper-crypted.device"
      ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt
        mount -t btrfs -o subvol=/ /dev/mapper/crypted /mnt

        if [ -e /mnt/root ]; then
          btrfs subvolume list -o /mnt/root |
            cut -f9 -d' ' |
            while read subvolume; do
              echo "Deleting nested subvolume: /$subvolume"
              btrfs subvolume delete "/mnt/$subvolume"
            done
          echo "Deleting root subvolume"
          btrfs subvolume delete /mnt/root
        fi

        echo "Creating fresh root subvolume"
        btrfs subvolume create /mnt/root

        umount /mnt
      '';
    };
  };

  flake.modules.homeManager.ephemeral-root = {
    ephemeralRoot.persist.directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Music"
      "Videos"
      "software"
      ".ssh"
      ".gnupg"
      ".local/share/keyrings"
    ];
  };
}
