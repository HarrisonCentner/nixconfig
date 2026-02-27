{
  flake.modules.homeManager.editor =
    { pkgs, inputs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        gh
        inputs.claude-code.packages.${pkgs.system}.claude-code-bun
      ];
    };
}
