{ mkCompletionAlias, ... }:
{
  flake.modules.homeManager.editor =
    {
      pkgs,
      claude-code,
      ...
    }:
    let
      claudius = mkCompletionAlias pkgs "agent-jail" (
        pkgs.writeShellScriptBin "claudius" ''
          exec agent-jail "$@" -- claude --dangerously-skip-permissions
        ''
      );
      geminidius = mkCompletionAlias pkgs "agent-jail" (
        pkgs.writeShellScriptBin "gemini-jail" ''
          exec agent-jail "$@" -- gemini --yolo
        ''
      );
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
      ephemeralRoot.persist.directories = [
        ".claude"
      ];
    };
}
