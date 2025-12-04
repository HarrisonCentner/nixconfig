{ config, ... }:
{
  flake.modules.homeManager.shell = {
    programs = {
      zsh = {
        enable = true;
        shellAliases = {
          cat = "bat";
          cd = "zoxide";
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
