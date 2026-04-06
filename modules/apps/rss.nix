{
  flake.modules.homeManager.rss =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gnome-feeds
      ];
    };
}
