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

      services.syncthing.openDefaultPorts = false;

      networking = {
        firewall = {
          enable = true;
          interfaces.tailscale0 = {
            allowedTCPPorts = [ 22000 ];
            allowedUDPPorts = [ 22000 ];
          };
        };
        nameservers = [ "1.1.1.1" ];
        networkmanager.enable = true;
      };

    };
}
