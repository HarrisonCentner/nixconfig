{
  flake.nixosModules.portable-hardware =
    { lib, ... }:
    {
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      boot = {
        # Broad set so the stick boots on arbitrary machines.
        initrd.availableKernelModules = [
          "xhci_pci"
          "ehci_pci"
          "ahci"
          "nvme"
          "usb_storage"
          "uas"
          "usbhid"
          "sd_mod"
          "sr_mod"
        ];
        initrd.kernelModules = [ ];
        kernelModules = [ ];
        extraModulePackages = [ ];

        # Boot anywhere via the removable-media fallback
        # (EFI/BOOT/BOOTX64.EFI); never touch a host's NVRAM.
        loader.efi.canTouchEfiVariables = lib.mkForce false;
      };

      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
      };
    };
}
