{
  flake.modules.homeManager.shell = {
    programs.sbox = {
      enable = true;
      # git worktrees need read access to the parent's .git directory
      allowParent = "read";
      shareHistory = "off";
      bind = {
        # claude code settings and conversation state
        "$HOME/.claude" = {};
        "$HOME/.claude.json" = {};
        # gh cli auth token and config
        "$HOME/.config/gh" = {};
        # infisical auth and secrets config
        "$HOME/.infisical" = {};
        # tmux socket so exomonad can spawn panes
        "$XDG_RUNTIME_DIR/tmux-$(id -u)" = {};
      };
    };
  };
}
