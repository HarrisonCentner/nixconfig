{
  flake.modules.homeManager =
    let
      hmFragment =
        { pkgs, ... }:
        let
          nsbox = pkgs.writeShellScriptBin "nsbox" ''
            exec ${pkgs.util-linux}/bin/nsenter -t "$1" -n -- "''${2:-zsh}"
          '';
          agent-jail = pkgs.writers.writeHaskellBin "agent-jail" {
            libraries = with pkgs.haskellPackages; [
              turtle
              optparse-applicative
              directory
              unix
              text
            ];
          } (builtins.readFile ./agent-jail.hs);
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
