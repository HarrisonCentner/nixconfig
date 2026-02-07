{ config, ... }:
{
  flake.modules.homeManager.shell = {pkgs, ...}: {
    programs = {
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
          bind -r j select-pane -D
          bind -r k select-pane -U
          bind -r l select-pane -R
          # allows shift+enter to do multilines in claude code
          bind -n S-Enter send-keys Escape "[13;2u"
          set -g mouse on
          set -s copy-command 'wl-copy'
          set -s set-clipboard on
          set -g default-command "${pkgs.zsh}/bin/zsh"
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          set-window-option -g mode-keys vi
        '';
        plugins = with pkgs.tmuxPlugins; [
          resurrect 
          continuum
          yank
        ];
      };
    };
  };
}
