{ writeHaskellBinCompleted, ... }:
{
  flake.modules.nixos.ai-agents = {
    systemd.user.slices.ai-agents = {
      description = "Resource slice for AI agent sessions";
      sliceConfig = {
        CPUAccounting = true;
        CPUQuota = "1000%";
        CPUWeight = 50;
        IOWeight = 50;
      };
    };
  };
  flake.modules.homeManager.ai-agents =
    { pkgs, ... }:
    let
      agent-jail = writeHaskellBinCompleted pkgs "agent-jail" {
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
          "$HOME/.local/share/nix" = { };
          "$XDG_RUNTIME_DIR/tmux-$(id -u)" = { };
        };
      };
    };
}
