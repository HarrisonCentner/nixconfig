{
  flake.modules.nixos.base =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      report = config.pathReport;

      pathList = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        readOnly = true;
      };

      homePaths =
        select:
        lib.concatLists (
          lib.mapAttrsToList (
            _: hm: map (p: "${hm.home.homeDirectory}/${p}") (select hm)
          ) config.home-manager.users
        );
      merge = system: home: lib.sort lib.lessThan (lib.unique (system ++ home));

      lines = lib.concatMapStrings (l: l + "\n");
      backupLines = lib.concatMap (
        source:
        [ source ] ++ map (e: "  - ${e}") (lib.filter (lib.hasPrefix "${source}/") report.backup.exclude)
      ) report.backup.directories;
    in
    {
      options.pathReport = {
        persist = {
          enabled = lib.mkOption {
            type = lib.types.bool;
            readOnly = true;
          };
          directories = pathList;
          files = pathList;
        };
        backup = {
          directories = pathList;
          exclude = pathList;
        };
      };

      config = {
        pathReport = {
          persist = {
            enabled = config.ephemeralRoot.enable;
            directories = merge config.ephemeralRoot.persist.directories (
              homePaths (hm: hm.ephemeralRoot.persist.directories)
            );
            files = merge config.ephemeralRoot.persist.files (homePaths (hm: hm.ephemeralRoot.persist.files));
          };
          backup = {
            directories = merge config.backup.directories (homePaths (hm: hm.backup.directories));
            exclude = merge config.backup.exclude (homePaths (hm: hm.backup.exclude));
          };
        };

        system.build.pathReport = pkgs.writeText "path-report-${config.networking.hostName}" ''
          # ${config.networking.hostName}

          ## persist (ephemeralRoot ${if report.persist.enabled then "enabled" else "disabled"})
          ${lines (report.persist.directories ++ report.persist.files)}
          ## backup (kopia)
          ${lines backupLines}'';
      };
    };
}
