{
  flake.modules.homeManager.editor =
    {
      pkgs,
      claude-code,
      exomonad,
      ...
    }:
    let
      mkAgentJail =
        name: agent: skipCmd:
        pkgs.writeShellScriptBin name ''
          pid=$(cut -d' ' -f4 /proc/self/stat)
          echo "Sandbox PID: $pid (use: nsbox $pid)"
          exec sbox -- ${agent} ${skipCmd} "$@"
        '';

      claudius = mkAgentJail "claudius" "claude" "--dangerously-skip-permissions";
      gemini-jail = mkAgentJail "gemini-jail" "gemini" "--yolo";
    in
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        gh
        claude-code
        gemini-cli
        exomonad
        claudius
        gemini-jail
      ];
      programs.zsh.shellAliases = {
        gemini = "gemini-jail";
      };

      ephemeralRoot.persist.directories = [
        ".claude"
      ];
    };
}
