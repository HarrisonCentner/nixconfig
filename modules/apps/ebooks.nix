{
  flake.modules.homeManager.ebooks =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        calibre
      ];
    };
}
