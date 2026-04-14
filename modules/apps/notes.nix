{
  flake.modules.homeManager.notes =
    { pkgs, ... }:
    {
      programs.obsidian.enable = true;

      ephemeralRoot.persist.directories = [
        ".config/obsidian"
      ];
    };
}
