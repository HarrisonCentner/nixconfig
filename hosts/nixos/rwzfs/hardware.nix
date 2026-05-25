{
  flake.nixosModules.rwzfs-hardware =
    {
      lib,
      ...
    }:
    {

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      boot = {
        initrd.availableKernelModules = [
          "xhci_pci"
          "thunderbolt"
          "nvme"
          "usb_storage"
          "sd_mod"
        ];
        initrd.kernelModules = [ ];
        kernelModules = [
          "kvm-intel"
          "iwlwifi"
          "8812au"
        ];
        extraModulePackages = [ ];
      };

      networking = {
        # nameservers managed by blocky (→ 127.0.0.1)
        networkmanager.enable = true;
        firewall.enable = false;
      };

    };
}
