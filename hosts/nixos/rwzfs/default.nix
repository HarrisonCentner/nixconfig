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
        docker
        microvm-host
        tailscale
      ]
      ++ [
        {
          home-manager.users.hcentner = {
            imports = with config.flake.modules.homeManager; [
              # Modules
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
              messaging
              music
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
