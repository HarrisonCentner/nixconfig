{
  flake.modules.nixos.base =
    { lib, ... }:
    {
      time.timeZone = lib.mkDefault "America/New_York";
    };
}
