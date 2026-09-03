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

  # opnix aborts on the first unresolvable reference, writing no secrets;
  # patched to write every resolvable secret and still exit non-zero.
  opnix-patched =
    let
      src = inputs.nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "opnix-partial-failure";
        src = inputs.opnix;
        patches = [ ./opnix-partial-failure.patch ];
      };
    in
    import "${src}/nix/module.nix";
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
        inputs.impermanence.nixosModules.impermanence
        opnix-patched
        {
          home-manager = {
            extraSpecialArgs = specialArgs // {
              claude-code = inputs.claude-code.packages."x86_64-linux".claude-code;
            };
            sharedModules = [
              inputs.sbox.homeManagerModules.sbox
            ];
            # sbox refuses to bind host-PATH entries under $HOME, so home
            # packages must land in /etc/profiles/per-user to be visible
            # inside the sandbox.
            useUserPackages = true;
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
