{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
   ./../../lab/default.nix
  ];

  services.openssh.enable = true;

  homelab.services.immich.enable = true;
  services.blocky.enable = true;
}
