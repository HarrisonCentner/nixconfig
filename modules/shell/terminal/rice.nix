{
  flake.modules = {
    homeManager.shell = {
      programs = {
        fastfetch = {
          enable = true;
        };
      };
    };
  };
}
