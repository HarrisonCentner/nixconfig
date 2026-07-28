{ inputs, ... }:
{
  flake.nixosModules.installer-common =
    { lib, pkgs, ... }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];

      # disko-install and `nixos-install --flake` both need these on the ISO.
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      environment.systemPackages = [
        inputs.disko.packages.x86_64-linux.disko-install
        pkgs.git
      ];

      networking = {
        wireless.enable = lib.mkForce false;
        networkmanager.enable = true;
      };
    };
}
