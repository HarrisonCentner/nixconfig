{ ... }:
{
  flake.modules.homeManager.shell = {
    programs = {
      zsh = {
        enable = true;
        shellAliases = {
          claude = "claude-bun";
          nsp = "nix-shell -p $@ --command zsh";
          q = "exit";
          tree = "ls --tree";
          v = "vim -u $HOME/.vimrc";
          vim = "vim -u $HOME/.vimrc";
          claudius = "claude-bun --dangerously-skip-permissions";
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
