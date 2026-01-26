{
  flake.nixosModules."zylphia/hardware" = { pkgs, lib, config, ...}: {

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    boot.initrd.availableKernelModules = [ "usb_storage" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "iwlwifi" "8812au" ];
    boot.extraModulePackages = with config.boot.kernelPackages; [ ];
    hardware.enableRedistributableFirmware = true;
    hardware.firmware = with pkgs; [ 
      linux-firmware 
    ];
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    networking.firewall.enable = false; 
    networking.nameservers = [ "1.1.1.1" ]; 
    networking.networkmanager.enable = true; 

  };
}
