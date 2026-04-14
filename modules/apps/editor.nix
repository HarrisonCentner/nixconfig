{
  flake.modules.homeManager.editor =
    { pkgs, claude-code, exomonad, ... }:
    let
      claudius = pkgs.writeShellScriptBin "claudius" ''
        pid=$(cut -d' ' -f4 /proc/self/stat)
        echo "Sandbox PID: $pid (use: nsbox $pid)"
        exec sbox -- claude-bun --dangerously-skip-permissions "$@"
      '';
    in
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        gh
        claude-code
        exomonad
        claudius
      ];
      programs.zsh.shellAliases.claude = "claude-bun";

      ephemeralRoot.persist.directories = [
        ".claude"
      ];
    };
}
