{
  config,
  lib,
  ...
}:
{
  flake.modules.darwin."hosts/darwin/xlthlx" = {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-darwin";
    imports =
      with config.flake.modules.darwin;
      [
        # Users
        base
        harrisoncentner
      ]
      ++ [
        {
          home-manager.users.harrisoncentner = {
            imports = with config.flake.modules.homeManager; [
              # Modules
              base
              shell
            ];
          };
        }
      ];
  };
}
