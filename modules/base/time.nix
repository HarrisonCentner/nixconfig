{
  flake.modules.nixos.base =
    { lib, config, ... }:
    let
      timeZones = {
        "New York" = "America/New_York";
        "Stockholm" = "Europe/Stockholm";
      };
    in
    {
      options.location.address = lib.mkOption {
        type = lib.types.enum (lib.attrNames timeZones);
        default = "New York";
      };

      config.time.timeZone = timeZones.${config.location.address};
    };
}
