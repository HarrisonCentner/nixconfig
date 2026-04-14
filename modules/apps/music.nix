{
  flake.modules.homeManager.music =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        spotify
      ];

      ephemeralRoot.persist.directories = [
        ".config/spotify"
      ];
    };
}
