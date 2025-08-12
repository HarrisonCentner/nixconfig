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

  outputs = inputs@{ nix-darwin, nixpkgs, home-manager, ... }:
    let
    configuration = { pkgs, ... }: {
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      # Binary Cache for haskell.nix
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
      nix.settings.substituters = [ ];

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";
 };
 in
 {
# Build darwin flake using:
# $ darwin-rebuild build --flake .#Harrisons-MacBook-Pro-7
    darwinConfigurations."Harrisons-MacBook-Pro-7" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        ./modules/system.nix
        
        home-manager.darwinModules.home-manager {
          home-manager = {
            # include the home-manager module
            users.harrisoncentner = import ./templates/home-manager/home.nix;
            useGlobalPkgs = true;
            useUserPackages = true;
          };
          users.users.harrisoncentner.home = "/Users/harrisoncentner";
          nix.settings.trusted-users = ["harrisoncentner"];
        }
      ];

    };
  };
}
