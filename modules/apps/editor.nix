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
        exec agent-jail -- claude --dangerously-skip-permissions "$@"
      '';
      claudius-host = pkgs.writeShellScriptBin "claudius-host" ''
        exec agent-jail --network host -- claude --dangerously-skip-permissions "$@"
      '';
      gemini-jail = pkgs.writeShellScriptBin "gemini-jail" ''
        exec agent-jail -- gemini --yolo "$@"
      '';
    in
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        claude-code
        claudius
        claudius-host
        exomonad
        gemini-cli
        gemini-jail
        gh
      ];
      programs.zsh.shellAliases = {
        gemini = "gemini-jail";
      };

      ephemeralRoot.persist.directories = [
        ".claude"
      ];
    };
}
