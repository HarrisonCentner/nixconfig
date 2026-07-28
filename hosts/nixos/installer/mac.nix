{
  config,
  inputs,
  ...
}:
{
  # The stock ISO has no apple-bce, so the internal keyboard, trackpad and wifi
  # are dead on a T2. Carries the same kernel and firmware as the host:
  #   nix build .#nixosConfigurations.installer-mac.config.system.build.isoImage
  flake.modules.nixos."hosts/nixos/installer-mac" =
    { lib, ... }:
    {
      imports = [
        config.flake.nixosModules.installer-common
        inputs.nixos-hardware.nixosModules.apple-t2
      ];

      nixpkgs.config.allowUnfreePredicate = pkg: lib.hasPrefix "brcm-firmware" (lib.getName pkg);

      hardware.apple-t2.firmware = {
        enable = true;
        version = "sonoma";
      };
    };
}
