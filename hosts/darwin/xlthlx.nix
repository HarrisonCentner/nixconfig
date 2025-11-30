{
  config,
  ...
}:
{
  flake.modules.darwin.xlthlx = {
    imports =
      with config.flake.modules.darwin;
      [
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
