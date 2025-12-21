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

        # Services
        blocky
        immich
        tailscale
      ]
      ++ [
        {
          home-manager.users.harrisoncentner = {
            imports = 
              with config.flake.modules.homeManager; 
              [
                # Modules
                base
                shell
              ];
          };
        }
      ];
  };
}
