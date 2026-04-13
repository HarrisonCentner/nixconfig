{
  flake.modules.homeManager.editor =
    { pkgs, inputs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        gh
        inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.claude-code-bun
        inputs.exomonad.packages.${pkgs.stdenv.hostPlatform.system}.exomonad
      ];
      programs.zsh.shellAliases = {
        claude = "claude-bun";
        claudius = "sbox -- claude-bun --dangerously-skip-permissions";
      };
    };
}
