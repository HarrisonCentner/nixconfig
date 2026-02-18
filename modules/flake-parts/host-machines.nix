{
  inputs,
  lib,
  config,
  ...
}:
let
  nixosPrefix = "hosts/nixos/";
  collectNixosHostsModules =
    modules: lib.filterAttrs (name: _: lib.hasPrefix nixosPrefix name) modules;
  darwinPrefix = "hosts/darwin/";
  collectDarwinHostsModules =
    modules: lib.filterAttrs (name: _: lib.hasPrefix darwinPrefix name) modules;
in
{
  flake.nixosConfigurations = lib.pipe (collectNixosHostsModules config.flake.modules.nixos) [
    (lib.mapAttrs' (
      name: module:
      let
        specialArgs = {
          inherit inputs;
          hostConfig = {
            name = lib.removePrefix nixosPrefix name;
          };
        };
      in
      {
        name = lib.removePrefix nixosPrefix name;
        value = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";
          modules = [
            module
            inputs.home-manager.nixosModules.home-manager
            inputs.disko.nixosModules.default
          ]
          ++ [
            {
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      }
    ))
  ];
  flake.darwinConfigurations = lib.pipe (collectDarwinHostsModules config.flake.modules.darwin) [
    (lib.mapAttrs' (
      name: module:
      let
        specialArgs = {
          inherit inputs;
          hostConfig = {
            name = lib.removePrefix darwinPrefix name;
          };
        };
      in
      {
        name = lib.removePrefix darwinPrefix name;
        value = inputs.nix-darwin.lib.darwinSystem {
          inherit specialArgs;
          modules = [
            module
            inputs.home-manager.darwinModules.home-manager
          ]
          ++ [
            {
              home-manager = {
                extraSpecialArgs = specialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
              };
            }
          ];
        };
      }
    ))
  ];
}
