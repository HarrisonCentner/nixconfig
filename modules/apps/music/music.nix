{ blockOutFromScreencast, ... }:
{
  flake.modules.homeManager.everyday =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        spotify
      ];

      wayland.windowManager.niri.settings._children = blockOutFromScreencast [ "(?i)^spotify$" ];

      ephemeralRoot.persist.directories = [
        ".config/spotify"
      ];
    };
}
