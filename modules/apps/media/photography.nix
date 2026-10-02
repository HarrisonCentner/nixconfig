{
  flake.modules.homeManager.photography =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        darktable
        gimp
        snapshot
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
