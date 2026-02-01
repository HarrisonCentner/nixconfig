{
  flake.modules.nixos.paperless = { pkgs, ... }:
  {
    services.paperless.enable = true;
  };
}
