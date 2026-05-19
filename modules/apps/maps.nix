{
  flake.modules.homeManager.everyday =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        gnome-maps
      ];
    };
}
