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
                sharedModules = [ inputs.sbox.homeManagerModules.sbox ];
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

            # Default isolated mode: in-jail invariants hold.
            machine.succeed(
                "runuser -l alice -c "
                "'cd ~/work/proj && agent-jail -- agent-jail-verify isolated'"
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
          '';
        };
    };
}
