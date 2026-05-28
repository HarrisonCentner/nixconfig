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
      gemini-jail = pkgs.writeShellScriptBin "gemini-jail" ''
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
