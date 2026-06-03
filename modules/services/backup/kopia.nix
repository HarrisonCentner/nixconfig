{ mkSecret, ... }:
{
  flake.modules.nixos.kopia-backup =
    {
      config,
      pkgs,
      ...
    }:
    let
      kopiaEnv = {
        KOPIA_CONFIG_PATH = "/var/lib/kopia/repository.config";
        KOPIA_CACHE_DIRECTORY = "/var/cache/kopia";
        KOPIA_LOG_DIR = "/var/log/kopia";
        HOME = "/var/lib/kopia";
      };
      common = {
        Type = "oneshot";
        User = "root";
        EnvironmentFile = config.age.secrets."kopia/env".path;
      };
    in
    {
      age.secrets."kopia/env" = mkSecret "root";

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
          ExecStart = "${pkgs.kopia}/bin/kopia snapshot create /home";
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
          ExecStart = "${pkgs.kopia}/bin/kopia maintenance run --full";
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
