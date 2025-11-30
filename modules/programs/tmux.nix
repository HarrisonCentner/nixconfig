{ config, ... }:
{
  flake.modules.homeManager.base.programs.tmux = {
    settings = {
      tmux = {
        enable = true;
        mouse = true;
        terminal = "xterm-256color";
        keyMode = "vi";
        baseIndex = 1;
        aggressiveResize = true;
        historyLimit = 250000;
        prefix = "C-space";
        sensibleOnTop = false;
        extraConfig = '' #
          bind -r h select-pane -L
          bind -r h select-pane -D
          bind -r k select-pane -U
          bind -r l select-pane -R
          set -g default-command /bin/zsh
        '';
      };
    };
  };
}
