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
        desktop
        config.flake.nixosModules.rwzfs-disko
        config.flake.nixosModules.rwzfs-hardware
        shell

        # Users
        hcentner

        # Apps
        ebooks
        password-manager

        # Services
        docker
        tailscale
      ]
      ++ [
        {
          home-manager.users.hcentner = {
            imports = with config.flake.modules.homeManager; [
              # Modules
              base
              desktop
              shell

              # Languages
              dhall
              haskell
              nix

              # Apps
              browser
              editor
              libreoffice
              messaging
              music
              notes
              photography

              # Services
              docker
            ];
          };
        }
      ];
  };
}
