{
  flake.modules.homeManager.photography =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        darktable
        gimp
      ];

      ephemeralRoot.persist.directories = [
        ".config/darktable"
        ".config/GIMP"
      ];
    };
}
