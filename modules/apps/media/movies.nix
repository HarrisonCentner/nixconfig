{
  renameDesktopEntryNamed,
  ...
}:
{
  flake.modules.homeManager.movies = { pkgs, ... }: {
    home.packages = with pkgs; [
      mpv
      (renameDesktopEntryNamed pkgs mpv "mpv" "mpv")
    ];
  };
}
