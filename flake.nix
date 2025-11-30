{
  description = "My hybrid nixos / nix-darwin system via dendritic nix and flake parts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    statix = {
      url = "github:molybdenumsoftware/statix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };

    stylix = {
      url = "github:nix-community/stylix";
      flake = true;
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # TODO: use quasigod/unify once it supports nix darwin
    hcentner-blog.url = "github:HarrisonCentner/blog";
  };

  outputs = inputs: 
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ 
        inputs.import-tree [
          ./modules 
          ./hosts
        ]
      ];
      _module.args.rootPath = ./.;
    };

#   {
#     nixosConfigurations.zylphia = 
#     let
#       username = "hcentner";
#       homeDirectory = "/home/${username}";
#       domain-name = "hcentner.com";
#       system = "x86_64-linux";
#     in
#     nixpkgs.lib.nixosSystem {
#       system = system;
#       specialArgs = {
#         inherit system username homeDirectory hcentner-blog; 
#       };
#       modules = [
#         disko.nixosModules.disko
#         ./machines/zylphia/default.nix
#         home-manager.nixosModules.home-manager
#         { home-manager = import ./home-manager/common.nix { inherit username homeDirectory; }; }
#         (import ./machines/common.nix { inherit username homeDirectory; })
#       ];
#     };

#     darwinConfigurations.xlthlx = 
#     let
#       username = "harrisoncentner";
#       homeDirectory = "/Users/${username}";
#     in
#     nix-darwin.lib.darwinSystem {
#       system = "x86_64-darwin"; 
#       modules = [
#         ./machines/xlthlx.nix
#         home-manager.darwinModules.home-manager 
#         { home-manager = import ./home-manager/common.nix { inherit username homeDirectory; }; }
#         (import ./machines/common.nix { inherit username homeDirectory; })
#       ];
#     };
#   };
}
