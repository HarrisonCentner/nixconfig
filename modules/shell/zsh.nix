{ config, ... }:
{
  flake.modules.homeManager.shell = {
    programs = {
      zsh = {
        enable = true;
        shellAliases = {
          cat = "bat";
          cd = "z";
          vim = "vim -u $HOME/.vimrc";
          tree = "ls --tree";
        };
        oh-my-zsh = {
          enable = true;
          plugins = [ "history" "git" ];
          theme = "eastwood";
        };
      };
    };
  };
}
