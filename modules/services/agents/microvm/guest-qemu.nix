{
  flake.modules.nixos.microvm-guest-qemu = {
    microvm = {
      hypervisor = "qemu";
      graphics.enable = true;
      qemu.extraArgs = [
        "-display"
        "gtk,gl=on,grab-on-hover=on"
      ];
    };
  };
}
