{
  inputs,
  ...
}:
{
  flake.modules.nixos.microvm-guest =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.microvm.nixosModules.microvm ];

      nix = {
        optimise.automatic = lib.mkForce false;
        channel.enable = false;
        settings = {
          accept-flake-config = true;
          substituters = [
            "https://devenv.cachix.org"
          ];
          trusted-public-keys = [
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
        };
      };
      boot.nixStoreMountOpts = [
        "nodev"
        "nosuid"
      ];
      environment.systemPackages = [
        pkgs.cachix
        pkgs.dconf
      ];
      programs.dconf.enable = true;
      networking.firewall.enable = false;
      zramSwap.enable = true;

      microvm = {
        writableStoreOverlay = "/nix/.rw-store";
      };
    };
}
