{
  microvmLib,
  ...
}:
{
  flake.modules.nixos.microvm-host =
    { pkgs, ... }:
    microvmLib.mkHostConfig {
      vmCount = 3;
      virtiofsdPackage = pkgs.virtiofsd;
    };
}
