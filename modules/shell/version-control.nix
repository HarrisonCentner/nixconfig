{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      programs = {
        lazygit = {
          enable = true;
          settings = {
            git.overrideGpg = true;
          };
        };
      };
    };
}
