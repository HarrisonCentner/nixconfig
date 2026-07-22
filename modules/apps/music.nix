{ blockOutFromScreencast, ... }:
{
  flake.modules.homeManager.everyday =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        spotify
      ];

      programs.niri.settings.window-rules = blockOutFromScreencast [ "(?i)^spotify$" ];

      ephemeralRoot.persist.directories = [
        ".config/spotify"
      ];
    };
}
