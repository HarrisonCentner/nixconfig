{
  flake.modules = {
    nixos.base.system.stateVersion = "25.11";
    darwin.base.system.stateVersion = 5;
    homeManager.base.home.stateVersion = "24.11";
  };
}
