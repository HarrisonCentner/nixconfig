{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    let
      nsbox = pkgs.writeShellScriptBin "nsbox" ''
        exec ${pkgs.util-linux}/bin/nsenter -t "$1" -n -- "''${2:-zsh}"
      '';
    in
    {
      home.packages = [ nsbox ];

      programs.sbox = {
        enable = true;
        # git worktrees need read access to the parent's .git directory
        allowParent = "read";
        network = "isolated";
        shareHistory = "off";
        bind = {
          # claude code settings and conversation state
          "$HOME/.claude" = { };
          "$HOME/.gemini" = { };
          "$HOME/.claude.json" = { };
          # gh cli auth token and config
          "$HOME/.config/gh" = { };
          # infisical auth and secrets config
          "$HOME/.infisical" = { };
          # tmux socket so exomonad can spawn panes
          "$XDG_RUNTIME_DIR/tmux-$(id -u)" = { };
          "$HOME/.cargo/bin/exomonad" = { };
        };
      };
    };
}
