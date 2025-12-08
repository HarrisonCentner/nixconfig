{
  flake.modules.homeManager.password-manager = { pkgs, ...}: {
    programs._1password-gui.enable = true;
    programs._1password.enable = true;
  };
}
