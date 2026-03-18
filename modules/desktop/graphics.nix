{
  flake.modules.nixos.intel-graphics =
    { pkgs, lib, config, ... }:
    {
      hardware = {
        enableRedistributableFirmware = true;
        firmware = with pkgs; [ linux-firmware ];
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            intel-vaapi-driver
          ];
        };
      };
    };
}
