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
  # slirp4netns's default 1500 MTU caps throughput below 1 Gbps and sbox
  # hardcodes its flags; rebuild the module from a patched source. Defined
  # here so flakes importing only this file still get it.
  flake.modules.homeManager.sbox-patched =
    let
      src = inputs.nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "sbox-slirp-mtu";
        src = inputs.sbox;
        postPatch = ''
          substituteInPlace sbox.nix \
            --replace-fail "slirp4netns --disable-host-loopback" "slirp4netns --mtu 65520 --disable-host-loopback"
        '';
      };
    in
    (import "${src}/nilla.nix").flakeOutputs.homeManagerModules.sbox;

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
        inputs.impermanence.nixosModules.impermanence
        {
          home-manager = {
            extraSpecialArgs = specialArgs // {
              claude-code = inputs.claude-code.packages."x86_64-linux".claude-code;
            };
            sharedModules = [
              config.flake.modules.homeManager.sbox-patched
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
