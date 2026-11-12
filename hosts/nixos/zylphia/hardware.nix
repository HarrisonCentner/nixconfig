{
  flake.nixosModules.zylphia-hardware =
    { lib, pkgs, ... }:
    {

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      boot.initrd = {
        availableKernelModules = [ "usb_storage" ];
        kernelModules = [ ];
      };

      # Haswell predates intel-media-driver (Broadwell+) and QSV; VA-API via i965 only
      hardware.graphics.extraPackages = [ pkgs.intel-vaapi-driver ];

      services = {
        immich.environment.LIBVA_DRIVER_NAME = "i965";
        syncthing.openDefaultPorts = false;
      };

      # kill the worst offender under sustained memory pressure instead of thrashing swap
      systemd = {
        oomd.enableSystemSlice = true;
        services.tailscaled.serviceConfig.ManagedOOMPreference = "avoid";
      };

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
