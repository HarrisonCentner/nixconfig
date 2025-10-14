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

  homelab.services.enable = true;
  homelab.services.immich.enable = true;
  homelab.services.blocky.enable = true;
  homelab.services.blog.enable = true;
}
