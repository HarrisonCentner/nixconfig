{
  flake.modules.nixos.base.boot = {
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
