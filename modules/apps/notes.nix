{
  flake.modules.homeManager.notes =
    { pkgs, ... }:
    {
      programs.obsidian.enable = true;
    };
}
