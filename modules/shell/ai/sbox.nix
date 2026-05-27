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
            sbox_args=()
            while [ $# -gt 0 ]; do
              case "$1" in
                --readable)
                  if [ $# -lt 2 ]; then
                    echo "agent-jail: --readable requires a directory argument" >&2
                    exit 1
                  fi
                  resolved=$(${pkgs.coreutils}/bin/realpath -- "$2") || {
                    echo "agent-jail: --readable: cannot resolve '$2'" >&2
                    exit 1
                  }
                  sbox_args=(--ro-bind "$resolved" "$resolved" "''${sbox_args[@]}")
                  shift 2
                  ;;
                *)
                  sbox_args+=("$1")
                  shift
                  ;;
              esac
            done

            worktree_args=()
            if common=$(${pkgs.git}/bin/git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) \
                && [ -d "$common" ] && [ "$common" != "$PWD/.git" ]; then
              worktree_args=(--bind "$common" "$common")
            fi
            echo "Sandbox PID: $$ (use: nsbox $$)"
            exec sbox "''${worktree_args[@]}" "''${sbox_args[@]}"
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
