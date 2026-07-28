{
  flake.modules.nixos.base =
    { pkgs, lib, ... }:
    {
      # mkDefault so hosts on a patched kernel (apple-t2) can win.
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };
}
