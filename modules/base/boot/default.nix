{
  flake.modules.nixos.base.boot = {
    initrd.systemd.enable = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };
}
