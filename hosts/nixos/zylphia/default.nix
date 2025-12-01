{
  config,
  ...
}:
{
  flake.modules.darwin.zylphia = {
    imports =
      with config.flake.modules.nixos;
      [
        # Modules
        base
        zylphia.disko

        # Users
        root
        ${userName}
      ]
      ++ [
        {
          home-manager.users.${userName} = {
            imports = 
              with config.flake.modules.homeManager; 
              [
                # Modules
                base
                languages.clojure
                languages.haskell
                languages.nix
                shell
                ${userName}
              ];
          };
        }
      ];
}
