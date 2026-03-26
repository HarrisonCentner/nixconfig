{
  flake.nixosModules.zylphia-hardware =
    {
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

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
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
