{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
   ./../../homelab/default.nix
  ];

  services.openssh.enable = true;

  homelab.services.immich.enable = true;
  

}
