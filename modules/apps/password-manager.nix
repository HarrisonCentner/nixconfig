{
  flake.modules.nixos.password-manager = { pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    programs._1password-gui.enable = true;
    programs._1password.enable = true;
  };
}
