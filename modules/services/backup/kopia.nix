{ mkOpSecret, ... }:
{
  flake.modules.nixos.base =
    { lib, ... }:
    {
      options.backup.directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };

  flake.modules.homeManager.base =
    { lib, ... }:
    {
      options.backup.directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
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
      hmDirs = lib.concatLists (
        lib.mapAttrsToList (
          _user: hm: map (d: "${hm.home.homeDirectory}/${d}") hm.backup.directories
        ) config.home-manager.users
      );
      sources = lib.unique (config.backup.directories ++ hmDirs);

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
          export KOPIA_PASSWORD="$(cat ${config.services.onepassword-secrets.secretPaths.kopiaPassword})"
          exec ${pkgs.kopia}/bin/kopia ${args}
        '';
    in
    {
      services.onepassword-secrets.secrets.kopiaPassword = mkOpSecret {
        service = "kopia-rwzfs";
        field = "password";
        owner = "root";
        services = [
          "kopia-backup"
          "kopia-maintenance"
        ];
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

      systemd.services.kopia-backup = {
        description = "Kopia snapshot";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        environment = kopiaEnv;
        serviceConfig = common // {
          ExecStart = kopiaExec "backup" "snapshot create ${lib.escapeShellArgs sources}";
        };
      };

      systemd.timers.kopia-backup = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };

      systemd.services.kopia-maintenance = {
        description = "Kopia repository maintenance (full)";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        environment = kopiaEnv;
        serviceConfig = common // {
          ExecStart = kopiaExec "maintenance" "maintenance run --full";
        };
      };

      systemd.timers.kopia-maintenance = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "monthly";
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
