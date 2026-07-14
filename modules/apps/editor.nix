{ mkCompletionAlias, ghTokenPath, ... }:
{
  flake.modules.homeManager.editor =
    {
      pkgs,
      claude-code,
      ...
    }:
    let
      # sbox does not clear the environment, so GH_TOKEN exported here is
      # inherited by the agent inside the sandbox.
      loadGhToken = ''export GH_TOKEN="$(cat ${ghTokenPath})"'';
      claudius = mkCompletionAlias pkgs "agent-jail" (
        pkgs.writeShellScriptBin "claudius" ''
          ${loadGhToken}
          exec agent-jail "$@" -- claude --dangerously-skip-permissions
        ''
      );
      geminidius = mkCompletionAlias pkgs "agent-jail" (
        pkgs.writeShellScriptBin "gemini-jail" ''
          ${loadGhToken}
          exec agent-jail "$@" -- gemini --yolo
        ''
      );
      stateDirs = [
        ".claude"
      ];
    in
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        claude-code
        claudius
        gemini-cli
        geminidius
        gh
      ];
      ephemeralRoot.persist.directories = stateDirs;
      backup.directories = stateDirs;
    };
}
