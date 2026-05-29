{
  flake.modules.homeManager.editor =
    {
      pkgs,
      claude-code,
      exomonad,
      ...
    }:
    let
      claudius = pkgs.writeShellScriptBin "claudius" ''
        exec agent-jail "$@" -- claude --dangerously-skip-permissions
      '';
      geminidius = pkgs.writeShellScriptBin "gemini-jail" ''
        exec agent-jail "$@" -- gemini --yolo
      '';
    in
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        claude-code
        claudius
        exomonad
        gemini-cli
        geminidius
        gh
      ];
      ephemeralRoot.persist.directories = [
        ".claude"
      ];
    };
}
