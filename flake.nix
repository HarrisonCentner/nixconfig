{
  description = "My hybrid nixos / nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-24.05";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let
    configuration = { ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      nix.settings.trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "haskell-miso-cachix.cachix.org-1:m8hN1cvFMJtYib4tj+06xkKt5ABMSGfe8W7s40x1kQ0="
      ];
      nix.settings.trusted-substituters = [
        "https://cache.iog.io"
        "https://nixcache.reflex-frp.org"
        "https://haskell-miso-cachix.cachix.org"

      ];
 };
    in {
      nixosConfigurations.zylphia = 
      let
        username = "hcentner";
        homeDirectory = "/home/${username}";
      in
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          configuration
          ./machines/zylphia.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users."${username}" = import ./home-manager/home.nix;
              extraSpecialArgs = { inherit username homeDirectory; };
              useGlobalPkgs = true;
              useUserPackages = true;
            };
            users.users."${username}".home = "${homeDirectory}";
            nix.settings.trusted-users = [ "${username}" ];
          }
        ];
      };

      darwinConfigurations.xlthlx = 
      let
        username = "hcentner";
        homeDirectory = "/Users/${username}";
      in
      nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin"; 
        modules = [
          configuration
          ./machines/xlthlx.nix
          home-manager.darwinModules.home-manager {
            home-manager = {
              users.${username} = import ./home-manager/home.nix;
              extraSpecialArgs = { inherit username homeDirectory; };
              useGlobalPkgs = true;
              useUserPackages = true;
            };
            users.users.${username}.home = "${homeDirectory}";
            nix.settings.trusted-users = [ "${username}" ];
          }
        ];
      };
    };
}
