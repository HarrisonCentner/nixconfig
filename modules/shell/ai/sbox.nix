{
  flake.modules.homeManager =
    let
      hmFragment =
        { pkgs, ... }:
        let
          nsbox = pkgs.writeShellScriptBin "nsbox" ''
            exec ${pkgs.util-linux}/bin/nsenter -t "$1" -n -- "''${2:-zsh}"
          '';
          agent-jail = pkgs.writeShellScriptBin "agent-jail" ''
            worktree_args=()
            if common=$(${pkgs.git}/bin/git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) \
                && [ -d "$common" ] && [ "$common" != "$PWD/.git" ]; then
              worktree_args=(--bind "$common" "$common")
            fi
            echo "Sandbox PID: $$ (use: nsbox $$)"
            exec sbox "''${worktree_args[@]}" "$@"
          '';
        in
        {
          home.packages = [
            nsbox
            agent-jail
          ];

          programs.sbox = {
            enable = true;
            network = "isolated";
            shareHistory = "off";
            shareKnownHosts = false;
            allowAudio = false;
            bind = {
              "$HOME/.claude" = { };
              "$HOME/.gemini" = { };
              "$HOME/.claude.json" = { };
              "$HOME/.config/gh" = { };
              "$HOME/.infisical" = { };
              "$XDG_RUNTIME_DIR/tmux-$(id -u)" = { };
              "$HOME/.cargo/bin/exomonad" = { };
            };
          };
        };
    in
    {
      shell = hmFragment;
      agentJail = hmFragment;
    };
}
