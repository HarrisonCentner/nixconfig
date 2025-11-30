{
  flake.modules.homeManager.shell = {
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
