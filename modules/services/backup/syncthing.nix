{
  flake.modules.nixos.base =
    { lib, ... }:
    {
      options.syncthing.folders = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
    };

  flake.modules.nixos.syncthing =
    { config, lib, ... }:
    {
      services.syncthing = {
        enable = true;
        user = "hcentner";
        group = "users";
        dataDir = "/home/hcentner";
        openDefaultPorts = true;
        overrideDevices = true;
        overrideFolders = true;
        settings = {
          devices = { };
          folders = lib.mapAttrs (_: path: { inherit path; }) config.syncthing.folders;
        };
      };
    };
}
