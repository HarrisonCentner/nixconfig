{
  description = "Configs for my nixos & nix-darwin systems using dendritic nix.";

  # All inputs with a `nixpkgs` input follow ours; the rest either have no
  # `nixpkgs` input to follow (flake-parts, import-tree, systems, sbox) or
  # are non-flake sources (superdirt, vowel, dirt-samples).
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sbox.url = "github:DavHau/sbox";
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixflix = {
      url = "github:kiriwalawren/nixflix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    superdirt = {
      url = "git+https://codeberg.org/musikinformatik/SuperDirt";
      flake = false;
    };
    vowel = {
      url = "github:supercollider-quarks/Vowel";
      flake = false;
    };
    dirt-samples = {
      url = "github:tidalcycles/Dirt-Samples";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree [
          ./modules
          ./hosts
          ./tests
        ])
      ];
      _module.args.rootPath = ./.;
    };
}
