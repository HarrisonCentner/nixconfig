{
  flake.modules.homeManager.editor =
    {
      pkgs,
      lib,
      claude-code,
      exomonad,
      ...
    }:
    let
      mkAgentJail =
        { name, agent, skipCmd, sboxArgs ? [ ] }:
        pkgs.writeShellScriptBin name ''
          pid=$(cut -d' ' -f4 /proc/self/stat)
          echo "Sandbox PID: $pid (use: nsbox $pid)"
          exec sbox ${lib.escapeShellArgs sboxArgs} -- ${agent} ${skipCmd} "$@"
        '';
      claudeOptions = {
        agent = "claude";
        skipCmd = "--dangerously-skip-permissions";
      };

      claudius = mkAgentJail (claudeOptions // {
        name = "claudius";
      });
      claudius-host = mkAgentJail (claudeOptions // {
        name = "claudius-host";
        sboxArgs = [ "--network" "host" ];
      });
      gemini-jail = mkAgentJail {
        name = "gemini-jail"; 
        agent = "gemini"; 
        skipCmd ="--yolo";
      };
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
