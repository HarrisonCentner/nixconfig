{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/zylphia" = {
    imports =
      with config.flake.modules.nixos;
      with config.flake.nixosModules;
      [
        # Modules
        ai-agents
        base
        zylphia-disko
        zylphia-hardware
        intel-graphics
        nix-mineral
        shell

        # Users
        hcentner

        # Apps
        password-manager

        # Services
        immich
        secrets
        syncthing
        tailscale
        paperless
        tailscale
      ]
      ++ [
        {
          home-manager.users.hcentner = {
            imports = with config.flake.modules.homeManager; [
              # Modules
              ai-agents
              base
              shell

              # Users
              hcentner

              # Languages
              haskell
              nix
              rust

              # Apps
              editor
              kopia-backup
            ];
          };
        }
      ];
  };
}
