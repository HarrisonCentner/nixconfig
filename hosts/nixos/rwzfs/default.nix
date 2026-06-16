{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/rwzfs" = {
    imports =
      with config.flake.modules.nixos;
      with config.flake.nixosModules;
      [
        # Modules
        ai-agents
        base
        rwzfs-disko
        rwzfs-hardware
        rwzfs-syncthing
        desktop-niri
        intel-graphics
        nix-mineral
        shell

        # Users
        hcentner

        # Apps
        library
        password-manager

        # Services
        dns
        docker
        kopia-backup
        microvm-host
        secrets
        syncthing
        tailscale
      ]
      ++ [
        {
          home-manager.users.hcentner = {
            imports = with config.flake.modules.homeManager; [
              # Modules
              ai-agents
              base
              desktop-niri
              noctalia-shell
              shell

              # Users
              hcentner

              # Languages
              clojure
              dhall
              haskell
              nix

              # Apps
              browser
              editor
              everyday
              library
              messaging
              notes
              office
              photography
              rss

              # Services
              cloud
              docker
              kopia-backup
            ];
          };
        }
      ];
  };
}
