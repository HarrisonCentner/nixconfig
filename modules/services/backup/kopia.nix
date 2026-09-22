{ mkOpSecret, ... }:
let
  region = "us-east-005";
  endpoint = "s3.${region}.backblazeb2.com";
in
{
  flake.modules.nixos.base =
    { lib, ... }:
    {
      options.backup = {
        directories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        exclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };
    };

  flake.modules.homeManager.base =
    { lib, ... }:
    {
      options.backup = {
        directories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        exclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };
    };

  flake.modules.nixos.kopia-backup =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.pathReport.backup) exclude;
      sources = config.pathReport.backup.directories;

      inherit (config.networking) hostName;
      secretPaths = config.services.onepassword-secrets.secretPaths;

      sourceIgnores =
        source: map (lib.removePrefix source) (lib.filter (lib.hasPrefix "${source}/") exclude);

      kopiaEnv = {
        KOPIA_CONFIG_PATH = "/var/lib/kopia/repository.config";
        KOPIA_CACHE_DIRECTORY = "/var/cache/kopia";
        KOPIA_LOG_DIR = "/var/log/kopia";
        HOME = "/var/lib/kopia";
      };
      common = {
        Type = "oneshot";
        User = "root";
      };
      kopiaExec =
        name: args:
        pkgs.writeShellScript "kopia-${name}" ''
          export KOPIA_PASSWORD="$(cat ${secretPaths.kopiaPassword})"
          exec ${pkgs.kopia}/bin/kopia ${args}
        '';

      storageArgs = lib.escapeShellArgs [
        "--bucket=${hostName}-backup"
        "--endpoint=${endpoint}"
        "--region=${region}"
      ];
      initScript = pkgs.writeShellScript "kopia-init" ''
        set -euo pipefail
        [ -e "$KOPIA_CONFIG_PATH" ] && exit 0

        export KOPIA_PASSWORD="$(cat ${secretPaths.kopiaPassword})"
        export AWS_ACCESS_KEY_ID="$(cat ${secretPaths.kopiaKeyId})"
        export AWS_SECRET_ACCESS_KEY="$(cat ${secretPaths.kopiaAppKey})"

        kopia=${pkgs.kopia}/bin/kopia
        # connect fails on an empty bucket, create fails on a populated one
        "$kopia" repository connect s3 ${storageArgs} \
          || "$kopia" repository create s3 ${storageArgs}
      '';
      backupScript = pkgs.writeShellScript "kopia-backup" ''
        set -uo pipefail
        export KOPIA_PASSWORD="$(cat ${secretPaths.kopiaPassword})"

        # a source absent on this host must not fail the whole snapshot
        present=()
        for src in ${lib.escapeShellArgs sources}; do
          if [ -e "$src" ]; then
            present+=("$src")
          else
            echo "kopia-backup: skipping missing source $src"
          fi
        done

        exec ${pkgs.kopia}/bin/kopia snapshot create "''${present[@]}"
      '';
      # make kopia declarative by clearing policy before each run
      ignoreSteps = map (
        source:
        let
          ignores = sourceIgnores source;
        in
        pkgs.writeShellScript "kopia-ignore-${baseNameOf source}" ''
          set -euo pipefail
          [ -e ${lib.escapeShellArg source} ] || exit 0
          export KOPIA_PASSWORD="$(cat ${secretPaths.kopiaPassword})"
          kopia=${pkgs.kopia}/bin/kopia
          "$kopia" policy set ${lib.escapeShellArg source} --clear-ignore
          ${lib.optionalString (ignores != [ ]) ''
            "$kopia" policy set ${lib.escapeShellArg source} ${
              lib.concatMapStringsSep " " (p: "--add-ignore ${lib.escapeShellArg p}") ignores
            }
          ''}
        ''
      ) sources;
    in
    {
      services.onepassword-secrets.secrets =
        let
          mkKopiaSecret =
            field:
            mkOpSecret {
              service = "kopia-${hostName}";
              inherit field;
              owner = "root";
              services = [
                "kopia-init"
                "kopia-backup"
                "kopia-maintenance"
              ];
            };
        in
        {
          kopiaPassword = mkKopiaSecret "password";
          kopiaKeyId = mkKopiaSecret "key_id";
          kopiaAppKey = mkKopiaSecret "app_key";
        };

      environment.systemPackages = [ pkgs.kopia ];

      ephemeralRoot.persist.directories = [
        "/var/lib/kopia"
      ];

      systemd.tmpfiles.rules = [
        "d /var/lib/kopia 0700 root root -"
        "d /var/cache/kopia 0700 root root -"
        "d /var/log/kopia 0755 root root -"
      ];

      systemd.services.kopia-init = {
        description = "Kopia repository connect";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        environment = kopiaEnv;
        serviceConfig = common // {
          RemainAfterExit = true;
          ExecStart = initScript;
        };
      };

      systemd.services.kopia-backup = {
        description = "Kopia snapshot";
        after = [
          "network-online.target"
          "kopia-init.service"
        ];
        wants = [ "network-online.target" ];
        requires = [ "kopia-init.service" ];
        environment = kopiaEnv;
        serviceConfig = common // {
          ExecStartPre = [
            (kopiaExec "policy" "policy set --global --compression=zstd")
          ]
          ++ ignoreSteps;
          ExecStart = backupScript;
        };
      };

      systemd.timers.kopia-backup = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };

      systemd.services.kopia-maintenance = {
        description = "Kopia repository maintenance (full)";
        after = [
          "network-online.target"
          "kopia-init.service"
        ];
        wants = [ "network-online.target" ];
        requires = [ "kopia-init.service" ];
        environment = kopiaEnv;
        serviceConfig = common // {
          ExecStart = kopiaExec "maintenance" "maintenance run --full";
        };
      };

      systemd.timers.kopia-maintenance = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "2h";
        };
      };
    };

  flake.modules.homeManager.kopia-backup =
    {
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        backblaze-b2
      ];
    };
}
