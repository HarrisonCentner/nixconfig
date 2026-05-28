{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/rwzfs" = {
    imports =
      with config.flake.modules.nixos;
      [
        # Modules
        ai-agents
        base
        config.flake.nixosModules.rwzfs-disko
        config.flake.nixosModules.rwzfs-hardware
        desktop-niri
        intel-graphics
        shell

        # Users
        hcentner

        # Apps
        ebooks
        password-manager

        # Services
        dns
        docker
        kopia-backup
        microvm-host
        secrets
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

              # Languages
              dhall
              haskell
              nix

              # Apps
              browser
              editor
              everyday
              messaging
              notes
              office
              photography
              rss

              # Services
              cloud
              docker
            ];
          };
        }
      ];
  };
}
