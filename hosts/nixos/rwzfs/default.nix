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
        config.flake.nixosModules."rwzfs-disko"
        config.flake.nixosModules."rwzfs-hardware"

        # Users
        hcentner
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
                messaging
                editor
                graphical
                browser
                password-manager
              ];
          };
        }
      ];
  };
}
