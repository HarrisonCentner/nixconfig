{ ... }:
{
  flake.modules.homeManager.shell = {
    programs = {
      zsh = {
        enable = true;
        shellAliases = {
          claude = "claude-bun";
          q = "exit";
          tree = "ls --tree";
          v = "vim -u $HOME/.vimrc";
          vim = "vim -u $HOME/.vimrc";
        };
        oh-my-zsh = {
          enable = true;
          plugins = [
            "history"
            "git"
          ];
          theme = "eastwood";
        };
      };
    };
  };
}
