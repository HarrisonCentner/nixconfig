{ inputs, mkOpSecret, ... }:
let
  port = 3004;
in
{
  flake.modules.nixos.sparkyfitness =
    { config, lib, ... }:
    let
      cfg = config.services.sparkyfitness;
    in
    {
      imports = [ inputs.sparkyfitness.nixosModules.sparkyfitness ];

      services = {
        onepassword-secrets.secrets.sparkyfitnessEnv = mkOpSecret {
          service = "sparkyfitness";
          field = "notesPlain";
          services = [
            "sparkyfitness"
            "sparkyfitness-db-init"
          ];
        };

        sparkyfitness = {
          enable = true;
          frontendUrl = "";
          environmentFile = config.services.onepassword-secrets.secretPaths.sparkyfitnessEnv;
          nginx.virtualHost = "sparkyfitness";
        };

        nginx.virtualHosts.sparkyfitness.listen = [
          {
            addr = "127.0.0.1";
            inherit port;
          }
        ];

        postgresqlBackup = {
          enable = true;
          databases = [ cfg.database.name ];
        };
      };

      tailscaleServices.sparkyfitness = port;

      # tailnet name lives in environmentFile
      systemd.services.sparkyfitness.environment.SPARKY_FITNESS_FRONTEND_URL = lib.mkForce null;

      ephemeralRoot.persist.directories = [
        cfg.stateDir
        config.services.postgresqlBackup.location
      ];

      backup.directories = [
        cfg.stateDir
        config.services.postgresqlBackup.location
      ];
    };
}
