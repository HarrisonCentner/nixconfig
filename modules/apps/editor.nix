{
  flake.modules.homeManager.editor =
    { pkgs, inputs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        gh
        inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.claude-code-bun
      ];
    };
}
