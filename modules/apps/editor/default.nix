{
  flake.modules.homeManager.editor = { pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs; [
      code-cursor
      docker
    ];
  };
}
