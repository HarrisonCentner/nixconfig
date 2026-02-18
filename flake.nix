{
 description = "My hybrid nixos / nix-darwin system via dendritic nix and flake parts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = { url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = inputs: 
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ 
        (inputs.import-tree [
          ./modules 
          ./hosts
        ])
      ];
      _module.args.rootPath = ./.;
    };
}
