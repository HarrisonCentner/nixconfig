{
  flake.nixosModules."rwzfs/hardware" = { pkgs, lib, config, ...}: {

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    boot = {
      initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
      initrd.kernelModules = [ ];
      kernelModules = [ "kvm-intel" "iwlwifi" "8812au" ];
      extraModulePackages = [ ];
    };

    hardware = {
      enableRedistributableFirmware = true;
      firmware = with pkgs; [ linux-firmware ];
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

    networking = {
      nameservers = [ "1.1.1.1" ]; # no google
      networkmanager.enable = true;
      firewall.enable = false;
    };

    console.useXkbConfig = true;

    services = {
      xserver = {
        enable = true;
        xkb.options = "caps:swapescape";
      };
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

  };
}
