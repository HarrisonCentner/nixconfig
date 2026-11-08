{
  flake.nixosModules.zylphia-hardware =
    { lib, ... }:
    {

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      boot.initrd = {
        availableKernelModules = [ "usb_storage" ];
        kernelModules = [ ];
      };

      # intel_cpufreq passive: powersave pins min freq
      powerManagement = {
        cpuFreqGovernor = "schedutil";
        powertop.enable = true;
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
