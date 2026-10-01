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
        biometrics
        rwzfs-disko
        rwzfs-hardware
        rwzfs-syncthing
        desktop-niri
        intel-graphics
        nix-mineral
        shell
        shell-host

        # Users
        hcentner

        # Apps
        library
        password-manager

        # Services
        cloud-media
        docker
        gnupg
        kopia-backup
        microvm-host
        music
        calendar
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
              shell-host

              # Users
              hcentner

              # Languages
              clojure
              dhall
              haskell
              nix
              rust

              # Apps
              browser
              editor
              everyday
              library
              messaging
              movies
              notes
              office
              password-manager
              photography
              rss
              tidal

              # Services
              cloud
              docker
              kopia-backup
              music
            ];
          };
        }
      ];
  };
}
