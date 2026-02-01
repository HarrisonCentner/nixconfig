{
  flake.modules.nixos.invidious = { pkgs, ... }:
  {
    services.invidious = {
      enable = true;
    };
  };
}
