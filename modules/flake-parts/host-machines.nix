{
  inputs,
  lib,
  config,
  ...
}:
let
  mkHosts =
    prefix: modules: builder:
    lib.mapAttrs' (
      name: module:
      let
        hostName = lib.removePrefix prefix name;
        specialArgs = {
          inherit inputs;
          hostConfig.name = hostName;
        };
      in
      {
        name = hostName;
        value = builder specialArgs module;
      }
    ) (lib.filterAttrs (name: _: lib.hasPrefix prefix name) modules);
in
{
  flake.nixosConfigurations = mkHosts "hosts/nixos/" config.flake.modules.nixos (
    specialArgs: module:
    inputs.nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      modules = [
        module
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.default
        inputs.niri.nixosModules.niri
        {
          home-manager = {
            extraSpecialArgs = specialArgs;
            sharedModules = [ inputs.sbox.homeManagerModules.sbox ];
          };
        }
      ];
    }
  );
  flake.darwinConfigurations = mkHosts "hosts/darwin/" config.flake.modules.darwin (
    specialArgs: module:
    inputs.nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        module
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = specialArgs;
            sharedModules = [ inputs.sbox.homeManagerModules.sbox ];
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
          };
        }
      ];
    }
  );
}
