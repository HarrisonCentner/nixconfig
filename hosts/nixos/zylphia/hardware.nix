{
  flake.nixosModules.zylphia-hardware =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      boot = {
        initrd = {
          availableKernelModules = [ "usb_storage" ];
          kernelModules = [ ];
        };
        kernelModules = [
          "iwlwifi"
          "8812au"
        ];
        extraModulePackages = with config.boot.kernelPackages; [ ];
      };
      hardware = {
        enableRedistributableFirmware = true;
        firmware = with pkgs; [
          linux-firmware
        ];
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            # intel-ocl (for now I don't need OpenCL)
            intel-vaapi-driver
          ];
        };
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            22
            80
            443
            2283 # immich
            28981 # paperless
          ];
        };
        nameservers = [ "1.1.1.1" ];
        networkmanager.enable = true;
      };

    };
}
