{ ... }:
{
  flake.modules.homeManager.shell = {
    programs = {
      zsh = {
        enable = true;
        shellAliases = {
          vim = "vim -u $HOME/.vimrc";
          v = "vim -u $HOME/.vimrc";
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
