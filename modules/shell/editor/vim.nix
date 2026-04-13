{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nodejs # required for coc-nvim
      ];
      xdg.desktopEntries = {
        vim = {
          name = "Vim";
          noDisplay = true;
        };
        gvim = {
          name = "GVim";
          noDisplay = true;
        };
      };
      programs = {
        vim = {
          enable = true;
        };
        zsh.shellAliases = {
          v = "vim -u $HOME/.vimrc";
          vim = "vim -u $HOME/.vimrc";
        };
      };
    };
}
