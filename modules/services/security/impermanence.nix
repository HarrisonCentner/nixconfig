{
  # Custom options that any module can write to unconditionally.
  # Only mapped to real impermanence config when a host imports ephemeral-root.
  flake.modules.nixos.base =
    { lib, config, ... }:
    {
      options.ephemeralRoot = {
        enable = lib.mkEnableOption "ephemeral root filesystem with impermanence";
        keepRoots = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 5;
        };
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
  flake.modules.nixos.ephemeral-root =
    { config, ... }:
    {
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
        description = "Archive btrfs root subvolume and start blank";
        wantedBy = [ "initrd.target" ];
        after = [
          "systemd-cryptsetup@crypted.service"
          "dev-mapper-crypted.device"
        ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        # Archive the old root instead of deleting it: an unpersisted directory
        # is then recoverable from /old_roots until pruned to keepRoots.
        script = ''
          mkdir -p /mnt
          mount -t btrfs -o subvol=/ /dev/mapper/crypted /mnt

          delete_subvolume_recursively() {
            for nested in $(btrfs subvolume list -o "$1" | cut -f9- -d' '); do
              delete_subvolume_recursively "/mnt/$nested"
            done
            btrfs subvolume delete "$1"
          }

          if [ -e /mnt/root ]; then
            mkdir -p /mnt/old_roots
            timestamp=$(date --date="@$(stat -c %Y /mnt/root)" "+%Y-%m-%d_%H:%M:%S")
            mv /mnt/root "/mnt/old_roots/$timestamp"
          fi

          for old in $(ls -1dt /mnt/old_roots/* 2>/dev/null | tail -n +${
            toString (config.ephemeralRoot.keepRoots + 1)
          }); do
            echo "Pruning old root: $old"
            delete_subvolume_recursively "$old"
          done

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
