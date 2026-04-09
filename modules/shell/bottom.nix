{
  flake.modules = {
    homeManager.shell = {
      programs = {
        bottom = {
          enable = true;
        };
      };
      xdg.desktopEntries.bottom = {
        name = "bottom";
        noDisplay = true;
      };
    };
  };
}
