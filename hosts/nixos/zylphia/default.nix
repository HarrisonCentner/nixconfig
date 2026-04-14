{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/zylphia" = {
    imports =
      with config.flake.modules.nixos;
      [
        # Modules
        base
        config.flake.nixosModules."zylphia-disko"
        config.flake.nixosModules.zylphia-hardware
        ephemeral-root
        intel-graphics
        shell

        # Users
        hcentner

        # Services
        immich
        tailscale
        paperless
        github-runner
      ]
      ++ [
        {
          home-manager.users.hcentner = {
            imports = with config.flake.modules.homeManager; [
              # Modules
              base
              ephemeral-root
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
