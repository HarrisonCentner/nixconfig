{
  flake.nixosModules."rwzfs-hardware" = { pkgs, lib, config, ...}: {

    boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" "iwlwifi" ];
    boot.extraModulePackages = [ ];
    
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.firmware = with pkgs; [ linux-firmware ];

    networking.firewall.enable = false; 
    networking.nameservers = [ "1.1.1.1" ]; 
    networking.networkmanager.enable = true; 
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.xkbOptions = "caps:swapescape";
    console.useXkbConfig = true;
    
    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    programs.firefox.enable = true;
    virtualisation.docker.enable = true;
  };
}
