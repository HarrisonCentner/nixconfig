{ config, inputs, ... }:
let
  aiAgentsHm = config.flake.modules.homeManager.ai-agents;
in
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      writeTurtleBin,
      ...
    }:
    lib.optionalAttrs (system == "x86_64-linux") {
      # The jail's /tmp binds from /var/tmp/agents, so it must not inherit
      # nix-mineral's noexec on /var/tmp. qemu test VMs override fileSystems
      # entirely, so this can only be asserted against the real host config.
      checks.agent-jail-tmp-exec =
        let
          options = config.flake.nixosConfigurations.rwzfs.config.fileSystems."/var/tmp/agents".options;
        in
        assert lib.elem "exec" options;
        assert !(lib.elem "noexec" options);
        pkgs.runCommand "agent-jail-tmp-exec" { } "touch $out";

      # The VM below sets useUserPackages, so it can't catch a host that
      # leaves home packages in ~/.nix-profile — a path sbox never binds.
      checks.agent-jail-user-packages =
        assert config.flake.nixosConfigurations.rwzfs.config.home-manager.useUserPackages;
        pkgs.runCommand "agent-jail-user-packages" { } "touch $out";

      checks.agent-jail =
        let
          verify = writeTurtleBin "agent-jail-verify" {
            src = ./agent-jail-verify.hs;
            extraLibraries = with pkgs.haskellPackages; [ directory ];
          };
        in
        pkgs.testers.runNixOSTest {
          name = "agent-jail";

          nodes.machine =
            { lib, pkgs, ... }:
            {
              imports = [ inputs.home-manager.nixosModules.home-manager ];

              users.users.alice = {
                isNormalUser = true;
                home = "/home/alice";
                uid = 1000;
                shell = pkgs.bashInteractive;
              };

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = [ config.flake.modules.homeManager.sbox-patched ];
                users.alice = {
                  imports = [ aiAgentsHm ];
                  home.stateVersion = "24.05";
                  # Override the production bind set with literal paths the
                  # verifier knows about. The production config uses $HOME and
                  # $XDG_RUNTIME_DIR expansions plus paths that don't exist in
                  # a fresh VM (tmux socket).
                  programs.sbox.bind = lib.mkForce {
                    "/home/alice/.claude" = { };
                    "/home/alice/.gemini" = { };
                  };
                };
              };

              environment.systemPackages = [
                verify
                pkgs.git
                # Records the command line agent-jail built, in the jail's /tmp
                # so the session dir it landed in is observable from the host.
                (pkgs.writeShellScriptBin "claude" ''
                  printf '%s\n' "$@" > /tmp/argv
                '')
              ];

              systemd.services.test-setup = {
                description = "Prepare alice's workspace for agent-jail tests";
                wantedBy = [ "multi-user.target" ];
                after = [ "local-fs.target" ];
                serviceConfig = {
                  Type = "oneshot";
                  User = "alice";
                  Group = "users";
                  RemainAfterExit = true;
                };
                path = with pkgs; [
                  git
                  coreutils
                ];
                script = ''
                  set -eu
                  cd /home/alice
                  mkdir -p work .ssh .claude .gemini

                  : > .ssh/id_test

                  mkdir -p work/sibling
                  : > work/sibling/sentinel

                  mkdir -p work/proj
                  cd work/proj
                  git init -q -b main
                  git config user.email "alice@example.com"
                  git config user.name  "Alice"
                  : > sentinel-in-main
                  git add sentinel-in-main
                  git commit -q -m "initial"

                  git worktree add -q -b feat ../proj-wt
                '';
              };
            };

          testScript = ''
            machine.wait_for_unit("multi-user.target")
            machine.wait_for_unit("test-setup.service")
            machine.succeed("systemctl is-system-running --wait")

            # Default isolated mode: in-jail invariants hold.
            machine.succeed(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail -- agent-jail-verify isolated'"
            )

            # /tmp is the disk-backed per-session dir, not sbox's tmpfs: a
            # write to /tmp inside the jail lands under /var/tmp/agents.
            machine.succeed(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail -- sh -c \"echo scratch > /tmp/sentinel\"'"
            )
            machine.succeed("grep -q scratch /var/tmp/agents/session.*/sentinel")

            # A --session-key reuses one dir, so a resumed session sees the
            # scratch files the earlier run left in /tmp.
            machine.succeed(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail --session-key k1 "
                "-- sh -c \"echo resumed > /tmp/keyed\"'"
            )
            machine.succeed(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail --session-key k1 "
                "-- grep -q resumed /tmp/keyed'"
            )
            machine.succeed("grep -q resumed /var/tmp/agents/session.k1/keyed")

            machine.fail(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail --session-key k2 -- test -e /tmp/keyed'"
            )

            # Path separators would escape /var/tmp/agents.
            machine.fail(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail --session-key ../escape -- true'"
            )

            # A predictable name pre-created by another user is refused.
            machine.succeed("mkdir -p /var/tmp/agents/session.stolen")
            machine.fail(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail --session-key stolen -- true'"
            )

            # A fresh claude is handed an id we pick, and that id names the
            # session dir, so resuming it later lands on the same /tmp.
            machine.succeed("runuser -l alice -c 'cd ~/work/proj && agent-jail -- claude'")
            machine.succeed(
                "f=$(echo /var/tmp/agents/session.*/argv); "
                "id=$(grep -x -A1 -- --session-id $f | tail -1); "
                "test \"$(dirname $f)\" = /var/tmp/agents/session.$id"
            )

            # An id given on the command line is reused as-is, not re-pinned.
            machine.succeed("rm /var/tmp/agents/session.*/argv")
            machine.succeed(
                "runuser -l alice -c 'cd ~/work/proj && agent-jail -- claude "
                "--resume 11111111-2222-3333-4444-555555555555'"
            )
            machine.succeed(
                "test -f /var/tmp/agents/"
                "session.11111111-2222-3333-4444-555555555555/argv"
            )
            machine.fail(
                "grep -qx -- --session-id /var/tmp/agents/"
                "session.11111111-2222-3333-4444-555555555555/argv"
            )

            # An id we cannot know up front leaves the dir unkeyed.
            machine.succeed("rm /var/tmp/agents/session.*/argv")
            machine.succeed(
                "runuser -l alice -c 'cd ~/work/proj && agent-jail -- claude --continue'"
            )
            machine.succeed("test -f /var/tmp/agents/session.*/argv")
            machine.fail("grep -qx -- --session-id /var/tmp/agents/session.*/argv")

            # Only claude is read this way; another program's --resume is
            # forwarded without keying the dir.
            machine.succeed(
                "runuser -l alice -c 'cd ~/work/proj && agent-jail -- "
                "true --resume 99999999-9999-9999-9999-999999999999'"
            )
            machine.fail(
                "test -d /var/tmp/agents/"
                "session.99999999-9999-9999-9999-999999999999"
            )

            # Blocked network: only `lo` reachable inside the sandbox.
            machine.succeed(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail --network blocked -- agent-jail-verify blocked'"
            )

            # Worktree: main repo's .git is bound, working tree stays hidden.
            machine.succeed(
                "runuser -l alice -c "
                "'cd ~/work/proj-wt && agent-jail -- agent-jail-verify worktree'"
            )

            # Cross-check: sibling stays invisible from a worktree, too.
            machine.fail(
                "runuser -l alice -c "
                "'cd ~/work/proj-wt && agent-jail -- test -e /home/alice/work/sibling'"
            )

            # sbox mounts /dev/kvm by default when the host has it. The
            # test VM has no nested virt, so create the node as a stand-in.
            machine.succeed("[ -c /dev/kvm ] || mknod -m 666 /dev/kvm c 10 232")
            machine.succeed(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail -- test -c /dev/kvm'"
            )
          '';
        };
    };
}
