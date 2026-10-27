{
  flake.modules.nixos.base =
    { lib, ... }:
    {
      options.syncthing = {
        devices = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                id = lib.mkOption { type = lib.types.str; };
                addresses = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ "dynamic" ];
                };
              };
            }
          );
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
        rwzfs = {
          id = "5WMJI7P-BZMFSZM-FCZCDIH-WXZQT3X-R65EOTV-GTT2B5E-2KBYRUE-UUI4NA7";
          addresses = [
            "tcp://100.93.141.99:22000"
            "dynamic"
          ];
        };
        iphone-13-pro = {
          id = "V4DFG35-C3ID5OQ-2TBE7EP-DPOYCAT-4PSLG32-AH4FPPV-MFHBWIA-UQZNMQ2";
          addresses = [
            "tcp://100.74.70.83:22000"
            "dynamic"
          ];
        };
      };

      services.syncthing = {
        enable = true;
        user = "hcentner";
        group = "users";
        dataDir = "/home/hcentner";
        openDefaultPorts = lib.mkDefault true;
        overrideDevices = true;
        overrideFolders = true;
        settings = {
          options = {
            globalAnnounceEnabled = false;
            localAnnounceEnabled = true;
            relaysEnabled = false;
            natEnabled = false;
            urAccepted = -1;
            crashReportingEnabled = false;
            releasesURL = "";
          };
          devices = lib.mapAttrs (_: d: { inherit (d) id addresses; }) config.syncthing.devices;
          folders = lib.mapAttrs (_: f: { inherit (f) id path devices; }) config.syncthing.folders;
        };
      };
    };
}
