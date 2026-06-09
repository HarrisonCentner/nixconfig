{
  flake.modules.homeManager.rss =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gnome-feeds
      ];

      ephemeralRoot.persist.directories = [
        ".local/share/gnome-feeds"
      ];
    };
}
