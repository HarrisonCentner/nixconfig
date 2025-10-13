{ username, homeDirectory,  ... }: 
{ 
    users."${username}" = import ./home.nix;
    extraSpecialArgs = { inherit username homeDirectory; };
    useGlobalPkgs = true;
    useUserPackages = true;
}
