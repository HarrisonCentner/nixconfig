{
  description = "My hybrid nixos / nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-25.05"; 
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    hcentner-blog.url = "github:HarrisonCentner/blog";
  };

  outputs = { 
      nixpkgs, 
      nix-darwin, 
      home-manager, 
      disko, 
      simple-nixos-mailserver, 
      hcentner-blog, 
      ... 
  }:
    {
      nixosConfigurations.zylphia = 
      let
        username = "hcentner";
        homeDirectory = "/home/${username}";
        domain-name = "hcentner.com";
        system = "x86_64-linux";
      in
      nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = {
          inherit system username homeDirectory hcentner-blog; # simple-nixos-mailserver;
        };
        modules = [
          disko.nixosModules.disko
          ./machines/zylphia/default.nix
          home-manager.nixosModules.home-manager
          { home-manager = import ./home-manager/common.nix { inherit username homeDirectory; }; }
          (import ./machines/common.nix { inherit username homeDirectory; })
        ];
      };

      darwinConfigurations.xlthlx = 
      let
        username = "harrisoncentner";
        homeDirectory = "/Users/${username}";
      in
      nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin"; 
        modules = [
          ./machines/xlthlx.nix
          home-manager.darwinModules.home-manager 
          { home-manager = import ./home-manager/common.nix { inherit username homeDirectory; }; }
          (import ./machines/common.nix { inherit username homeDirectory; })
        ];
      };
    };
}
