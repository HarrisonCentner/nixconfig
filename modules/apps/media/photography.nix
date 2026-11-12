{ renameDesktopEntry, ... }:
{
  flake.modules.homeManager.photography =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        darktable
        gimp
        snapshot
        (renameDesktopEntry pkgs gimp "GIMP")
      ];

      ephemeralRoot.persist.directories = [
        ".config/darktable"
        ".config/GIMP"
      ];
      backup.directories = [
        ".config/darktable"
      ];
    };
}
