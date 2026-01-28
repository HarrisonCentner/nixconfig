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
        config.flake.nixosModules."zylphia/hardware"
        shell

        # Services
        ssh
        blocky
        immich
        tailscale
      ]
      ++ [
        {
          home-manager.users.hcentner = {
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
