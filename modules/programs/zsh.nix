{ config, ... }:
{
  flake.modules.homeManager.base.programs.zsh = {
    settings = {
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = [ "history" "git" ];
          theme = "eastwood";
        };
      };
    };
  };
}
