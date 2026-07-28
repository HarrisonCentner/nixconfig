{ inputs, ... }:
{
  flake.nixosModules.xlthlx-hardware =
    { lib, ... }:
    {
      imports = [ inputs.nixos-hardware.nixosModules.apple-t2 ];

      nixpkgs = {
        hostPlatform = lib.mkDefault "x86_64-linux";
        # Broadcom blobs lifted out of the macOS image.
        config.allowUnfreePredicate = pkg: lib.hasPrefix "brcm-firmware" (lib.getName pkg);
      };

      hardware = {
        # Wi-Fi/Bluetooth blobs are extracted from a macOS recovery image
        # downloaded at build time; the extraction runs in a VM, so the
        # builder needs KVM.
        apple-t2.firmware = {
          enable = true;
          version = "sonoma";
        };
        apple.touchBar.enable = true;
      };

      boot = {
        # apple-bce (keyboard, trackpad, audio) is put in the initrd by the
        # apple-t2 module, along with the linux-t2 kernel.
        initrd.availableKernelModules = [
          "xhci_pci"
          "nvme"
          "usb_storage"
          "usbhid"
          "sd_mod"
        ];
        kernelModules = [ "kvm-intel" ];

        # Apple firmware drops EFI boot entries added from Linux; boot the
        # removable-media fallback (EFI/BOOT/BOOTX64.EFI) off the Option-key
        # picker instead.
        loader.efi.canTouchEfiVariables = lib.mkForce false;
      };

      networking = {
        networkmanager.enable = true;
        firewall.enable = true;
      };
    };
}
