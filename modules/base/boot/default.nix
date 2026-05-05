{
  flake.modules.nixos.base.boot = {
    initrd.systemd.enable = true;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 8;
      };
      efi.canTouchEfiVariables = true;
    };

    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };
}
