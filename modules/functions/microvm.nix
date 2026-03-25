{
  lib,
  ...
}:
{
  _module.args.microvmLib = {
    mkGuestConfig =
      {
        n,
        flakeModules,
        nixosModules ? [ ],
        homeManagerModules ? [ ],
        mem ? 8192,
        vcpu ? 6,
        storeOverlaySize ? 8192,
        dataSize ? 16384,
        volumeFsType ? null,
        shareStore ? true,
      }:
      let
        mac = "02:00:00:00:00:0${toString n}";
        guestAddress = "10.0.100.${toString (n * 4 + 2)}/30";
        gatewayAddress = "10.0.100.${toString (n * 4 + 1)}";
        mkVolume =
          args:
          lib.mkMerge [
            args
            (lib.optionalAttrs (volumeFsType != null) { fsType = volumeFsType; })
          ];
      in
      {
        imports =
          (with flakeModules.nixos; [
            base
            microvm-guest
            root
            microvm-agent
            ssh
          ])
          ++ nixosModules;

        home-manager.users.microvm-agent = {
          imports =
            (with flakeModules.homeManager; [
              base
              shell
            ])
            ++ homeManagerModules;
        };

        microvm = {
          inherit mem vcpu;

          interfaces = [
            {
              type = "tap";
              id = "vm-qwfwq${toString n}";
              inherit mac;
            }
          ];

          shares = lib.optionals shareStore [
            {
              proto = "virtiofs";
              tag = "nix-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              socket = "/var/lib/microvms/qwfwq_${toString n}/virtiofs-nix-store.sock";
            }
          ];

          volumes = [
            (mkVolume {
              image = "/var/lib/microvms/qwfwq_${toString n}/nix-store-overlay.img";
              mountPoint = "/nix/.rw-store";
              size = storeOverlaySize;
            })
            (mkVolume {
              image = "/var/lib/microvms/qwfwq_${toString n}/data.img";
              mountPoint = "/data";
              size = dataSize;
            })
          ];
        };

        systemd = {
          network = {
            enable = true;
            networks."20-eth0" = {
              matchConfig.MACAddress = mac;
              networkConfig = {
                Address = guestAddress;
                DNS = [ "1.1.1.1" ];
              };
              routes = [ { Gateway = gatewayAddress; } ];
            };
          };
          tmpfiles.rules = [
            "d /data/home/microvm-agent 0700 microvm-agent users -"
          ];
        };

        fileSystems."/home" = {
          device = "/data/home";
          fsType = "none";
          options = [ "bind" ];
          depends = [ "/data" ];
        };
      };

    mkHostConfig =
      {
        vmCount,
        virtiofsdPackage,
      }:
      let
        vmIndices = builtins.genList (n: n + 1) vmCount;
        vmName = n: "qwfwq_${toString n}";
        mkVmNetwork = n: {
          "10-vm-qwfwq${toString n}" = {
            matchConfig.Name = "vm-qwfwq${toString n}";
            networkConfig = {
              Address = "10.0.100.${toString (n * 4 + 1)}/30";
              IPv4Forwarding = true;
              IPv6Forwarding = true;
            };
          };
        };
        mkVirtiofsd = n: {
          "virtiofsd-${vmName n}" = {
            description = "virtiofsd for ${vmName n}";
            serviceConfig = {
              Type = "simple";
              ExecStart = builtins.concatStringsSep " " [
                "${virtiofsdPackage}/bin/virtiofsd"
                "--socket-path=/var/lib/microvms/${vmName n}/virtiofs-nix-store.sock"
                "--shared-dir=/nix/store"
                "--cache=auto"
                "--thread-pool-size=4"
              ];
              Restart = "on-failure";
            };
            wantedBy = [ "multi-user.target" ];
          };
        };
      in
      {
        systemd = {
          tmpfiles.rules = [
            "d /var/lib/microvms 0777 root root -"
          ]
          ++ map (n: "d /var/lib/microvms/${vmName n} 0777 root root -") vmIndices;
          network = {
            enable = true;
            networks = lib.mkMerge (map mkVmNetwork vmIndices);
          };
          services = lib.mkMerge (map mkVirtiofsd vmIndices);
        };

        networking.nat = {
          enable = true;
          externalInterface = "wlp0s20f3";
          internalInterfaces = map (n: "vm-qwfwq${toString n}") vmIndices;
        };
      };
  };
}
