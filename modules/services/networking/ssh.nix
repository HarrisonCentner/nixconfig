{
  flake.modules.nixos.ssh =
    { pkgs, ... }:
    {
      services.openssh.enable = true;
    };
}
