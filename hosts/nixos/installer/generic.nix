{ config, ... }:
{
  # Plain install/rescue media:
  #   nix build .#nixosConfigurations.installer.config.system.build.isoImage
  flake.modules.nixos."hosts/nixos/installer".imports = [
    config.flake.nixosModules.installer-common
  ];
}
