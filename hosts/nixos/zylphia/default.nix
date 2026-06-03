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
        base
        zylphia-disko
        zylphia-hardware
        intel-graphics
        shell

        # Users
        hcentner

        # Services
        immich
        nixflix
        secrets
        tailscale
        paperless
      ]
      ++ [
        {
          home-manager.users.hcentner = {
            imports = with config.flake.modules.homeManager; [
              # Modules
              base
              shell

              # Languages
              haskell
              nix

              # Apps
              editor
            ];
          };
        }
      ];
  };
}
