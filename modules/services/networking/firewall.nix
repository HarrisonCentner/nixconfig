{
  flake.modules.nixos.firewall =
    { ... }:
    {
      networking.firewall.enable = true;
    };
}
