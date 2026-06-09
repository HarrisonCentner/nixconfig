{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          nodejs # required for coc-nvim
        ];
        sessionVariables.EDITOR = "vim";
        file = {
          ".vimrc".source = ./vimrc.txt;
          ".vim/coc-settings.json".source = ./coc-settings.json;
        };
      };
      xdg = {
        desktopEntries = {
          vim = {
            name = "Vim";
            exec = "ghostty -e vim %F";
            noDisplay = true;
            mimeType = [ "text/plain" ];
          };
        };
        mimeApps = {
          enable = true;
          defaultApplications."text/plain" = "vim.desktop";
        };
      };
      programs = {
        vim = {
          enable = true;
          packageConfigurable = pkgs.vim;
        };
        zsh.shellAliases = {
          v = "vim -u $HOME/.vimrc";
          vim = "vim -u $HOME/.vimrc";
        };
      };
    };
}
