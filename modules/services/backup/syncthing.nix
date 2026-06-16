{
  flake.modules.nixos.base =
    { lib, ... }:
    {
      options.syncthing = {
        devices = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
        };
        folders = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, ... }:
              {
                options = {
                  id = lib.mkOption {
                    type = lib.types.str;
                    default = name;
                  };
                  path = lib.mkOption { type = lib.types.str; };
                  devices = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                  };
                };
              }
            )
          );
          default = { };
        };
      };
    };

  flake.modules.nixos.syncthing =
    { config, lib, ... }:
    {
      syncthing.devices = {
        rwzfs = "5WMJI7P-BZMFSZM-FCZCDIH-WXZQT3X-R65EOTV-GTT2B5E-2KBYRUE-UUI4NA7";
        iphone-13-pro = "V4DFG35-C3ID5OQ-2TBE7EP-DPOYCAT-4PSLG32-AH4FPPV-MFHBWIA-UQZNMQ2";
      };

      services.syncthing = {
        enable = true;
        user = "hcentner";
        group = "users";
        dataDir = "/home/hcentner";
        openDefaultPorts = true;
        overrideDevices = true;
        overrideFolders = true;
        settings = {
          options = {
            globalAnnounceEnabled = false;
            localAnnounceEnabled = true;
            relaysEnabled = false;
            natEnabled = false;
          };
          devices = lib.mapAttrs (_: id: {
            inherit id;
            addresses = [ "dynamic" ];
          }) config.syncthing.devices;
          folders = lib.mapAttrs (_: f: { inherit (f) id path devices; }) config.syncthing.folders;
        };
      };
    };
}
