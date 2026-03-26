{
  flake.modules.homeManager.shell = {
    programs = {
      lsd = {
        enable = true;
        icons = {
          extension = { };
          filetype = { };
        };
      };
      zsh.shellAliases = {
        tree = "ls --tree";
      };
    };
  };
}
