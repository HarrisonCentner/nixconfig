{
  flake.modules.homeManager.editor =
    { pkgs, inputs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = [
        inputs.claude-code.packages.${pkgs.system}.claude-code-bun
      ];
    };
}
