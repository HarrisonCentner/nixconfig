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
        config.flake.nixosModules."rwzfs/disko"
        config.flake.nixosModules."rwzfs/hardware"
        shell

        # Users
        hcentner

        # Apps
        password-manager

        # Services
        tailscale
        docker
      ]
      ++ [
        {
          home-manager.users.hcentner = {
            imports = 
              with config.flake.modules.homeManager; 
              [
                # Modules
                base
                desktop
                shell

                # languages
                dhall
                haskell
                nix

                # Apps
                browser
                ebooks
                editor
                messaging

                # Apps
                docker
              ];
          };
        }
      ];
  };
}
