{
  flake.modules = {
    homeManager.shell =
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

    homeManager.desktop =
      { pkgs, lib, ... }:
      {
        xdg = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
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
      };
  };
}
