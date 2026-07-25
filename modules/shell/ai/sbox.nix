{ writeHaskellBinCompleted, mkOpSecret, ... }:
let
  ghTokenPath = "/var/lib/opnix/secrets/ghToken";
in
{
  _module.args.ghTokenPath = ghTokenPath;

  flake.modules.nixos.ai-agents = {
    systemd.user.slices.ai-agents = {
      description = "Resource slice for AI agent sessions";
      sliceConfig = {
        CPUAccounting = true;
        CPUQuota = "1000%";
        CPUWeight = 50;
        IOWeight = 50;
        # Fork-bomb backstop; counts threads, so parallel builds need headroom.
        TasksMax = 8192;
      };
    };

    # agent-jail binds a session dir from here over the jail's /tmp, and a
    # bind inherits nix-mineral's noexec on /var/tmp. Sticky mode so users
    # can create their own session dirs, as under /var/tmp itself.
    fileSystems."/var/tmp/agents" = {
      device = "/var/tmp/agents";
      fsType = "none";
      options = [
        "bind"
        "exec"
        "nosuid"
        "nodev"
      ];
    };
    systemd.tmpfiles.rules = [ "d /var/tmp/agents 1777 root root -" ];

    services.onepassword-secrets.secrets.ghToken = mkOpSecret {
      service = "github-rwzfs";
      field = "token";
      owner = "hcentner";
      services = [ ];
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
        pkgs.cloud-hypervisor
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
          "$HOME/.cache/cargo-target" = { };
          "$HOME/.cache/sccache" = { };
          "$HOME/.infisical" = { };
          "$HOME/.local/share/nix" = { };
          "$XDG_RUNTIME_DIR/tmux-$(id -u)" = { };
        };
        bindReadOnly = {
          "$HOME/.cargo/config.toml" = { };
        };
      };
    };
}
