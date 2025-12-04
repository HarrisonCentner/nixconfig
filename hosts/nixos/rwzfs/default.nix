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
        rwzfs.disko

        # Users
        # root
        # userName
      ]
      ++ [
        {
          home-manager.users.${userName} = {
            imports = 
              with config.flake.modules.homeManager; 
              [
                # Modules
                base
                # languages.clojure
                # languages.haskell
                # languages.nix
                shell
                # userName
              ];
          };
        }
      ];
  };
}
