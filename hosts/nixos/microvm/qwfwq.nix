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
        desktop
        microvm-guest-qemu
        docker
      ];
      homeManagerModules = with config.flake.modules.homeManager; [
        desktop
        browser
      ];
    })
    (mkQwfwq 2 {
      nixosModules = with config.flake.modules.nixos; [
        microvm-guest-firecracker
      ];
      shareStore = false;
    })
    (mkQwfwq 3 {
      nixosModules = with config.flake.modules.nixos; [
        microvm-guest-cloud-hypervisor
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
