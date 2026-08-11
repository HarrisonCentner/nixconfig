{
  flake.nixosModules."zylphia-disko" =
    { pkgs, disko, ... }:
    {
      fileSystems."/home".neededForBoot = true;
      fileSystems."/persist".neededForBoot = true;

      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/vdb";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "crypted";
                    settings = {
                      allowDiscards = true;
                      bypassWorkqueues = true;
                    };
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      subvolumes = {
                        "/root" = {
                          mountpoint = "/";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/home" = {
                          mountpoint = "/home";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/nix" = {
                          mountpoint = "/nix";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        # Survives the root rollback; backs environment.persistence."/persist".
                        "/persist" = {
                          mountpoint = "/persist";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        # nodatacow: databases fragment badly under btrfs CoW.
                        "/postgresql" = {
                          mountpoint = "/var/lib/postgresql";
                          mountOptions = [
                            "nodatacow"
                            "noatime"
                          ];
                        };
                        "/swap" = {
                          mountpoint = "/.swapvol";
                          swap.swapfile.size = "32G";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}
