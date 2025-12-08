{
  flake.nixosModules."rwzfs-hardware" = { pkgs, lib, config, ...}: {

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" "iwlwifi" ];
    boot.extraModulePackages = [ ];
    hardware.enableRedistributableFirmware = true;
    hardware.firmware = with pkgs; [ linux-firmware ];
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    

    networking.firewall.enable = false; 
    networking.nameservers = [ "1.1.1.1" ]; 
    networking.networkmanager.enable = true; 

    services.xserver.enable = true;
    services.xserver.xkbOptions = "caps:swapescape";
    console.useXkbConfig = true;
    
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    virtualisation.docker.enable = true;
  };
}
