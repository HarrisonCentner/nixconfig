{
  flake.modules.nixos.microvm-guest-qemu = {
    microvm = {
      hypervisor = "qemu";
      graphics.enable = true;
    };
  };
}
