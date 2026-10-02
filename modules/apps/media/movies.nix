{
  ...
}:
{
  flake.modules.homeManager.movies = { pkgs, ... }: {
    home.packages = with pkgs; [
      mpv
    ];
  };
}
