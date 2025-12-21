{
  flake.modules.nixos.tailscale = { pkgs, ... }:
  {
    services.paperless.enable = true;
  };
}
