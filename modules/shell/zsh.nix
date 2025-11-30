{ config, ... }:
{
  flake.modules.homeManager.shell = {
    settings = {
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = [ "history" "git" ];
          theme = "eastwood";
          shellAliases = {
            ll = "ls -l";
            ls = "lsd";
            cat = "bat";
            cd = "zoxide";
          };
        };
      };
    };
  };
}
