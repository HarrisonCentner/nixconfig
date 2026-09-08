{ mkCompletionAlias, ghTokenPath, ... }:
{
  flake.modules.homeManager.editor =
    {
      pkgs,
      lib,
      claude-code,
      ...
    }:
    let
      # sbox does not clear the environment, so GH_TOKEN exported here is
      # inherited by the agent inside the sandbox. The token lives on tmpfs,
      # so it is absent until opnix-secrets.service has run.
      loadGhToken = ''
        if [ -r ${ghTokenPath} ]; then
          export GH_TOKEN="$(cat ${ghTokenPath})"
        else
          echo "warning: opnix secrets unavailable (${ghTokenPath}); GH_TOKEN unset" >&2
        fi
      '';
      # bwrap refuses a missing bind source, so state is seeded on the host.
      mkJail =
        {
          name,
          dirs ? [ ],
          files ? [ ],
          command,
        }:
        let
          writeable = lib.concatMapStringsSep " " (p: ''--writeable "$HOME/${p}"'') (dirs ++ files);
        in
        mkCompletionAlias pkgs "agent-jail" (
          pkgs.writeShellScriptBin name ''
            ${loadGhToken}
            ${lib.concatMapStringsSep "\n" (d: ''mkdir -p "$HOME/${d}"'') dirs}
            ${lib.concatMapStringsSep "\n" (f: ''[ -e "$HOME/${f}" ] || echo '{}' > "$HOME/${f}"'') files}
            exec agent-jail ${writeable} "$@" -- ${command}
          ''
        );
      claudius = mkJail {
        name = "claudius";
        dirs = [ ".claude" ];
        files = [ ".claude.json" ];
        command = "claude --dangerously-skip-permissions";
      };
      antigravity-jail = mkJail {
        name = "agy-jail";
        dirs = [ ".gemini" ];
        command = "agy --dangerously-skip-permissions";
      };
      codex-jail = mkJail {
        name = "codex-jail";
        dirs = [ ".codex" ];
        command = "codex --dangerously-bypass-approvals-and-sandbox";
      };
      stateDirs = [
        ".claude"
        ".codex"
        ".gemini"
      ];
    in
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        antigravity-cli
        antigravity-jail
        claude-code
        claudius
        codex
        codex-jail
        gh
      ];
      ephemeralRoot.persist.directories = stateDirs;
      backup.directories = stateDirs;
    };
}
