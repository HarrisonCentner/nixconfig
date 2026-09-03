{
  config,
  lib,
  microvmLib,
  ...
}:
let
  flakeModules = config.flake.modules;
  mkQwfwq = n: args: {
    "hosts/nixos/qwfwq_${toString n}" = microvmLib.mkGuestConfig ({ inherit n flakeModules; } // args);
  };
in
{
  flake.modules.nixos = lib.mkMerge [
    (mkQwfwq 1 {
      nixosModules = with config.flake.modules.nixos; [
        desktop-niri
        microvm-guest-qemu
        nix-mineral-strict
        openssh
      ];
      homeManagerModules = with config.flake.modules.homeManager; [
        desktop-niri
        noctalia-shell
        browser
      ];
    })
    (mkQwfwq 2 {
      nixosModules = with config.flake.modules.nixos; [
        microvm-guest-firecracker
        nix-mineral-strict
      ];
      shareStore = false;
    })
    (mkQwfwq 3 {
      nixosModules = with config.flake.modules.nixos; [
        microvm-guest-cloud-hypervisor
        nix-mineral-strict
        {
          microvm = {
            balloon = true;
            deflateOnOOM = true;
          };
        }
      ];
      volumeFsType = "btrfs";
    })
  ];
}
