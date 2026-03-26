{
  inputs,
  ...
}:
{
  flake.modules.nixos.attic =
    { ... }:
    {
      imports = [ inputs.attic.nixosModules.atticd ];

      services.atticd = {
        enable = true;

        # file containing ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64
        environmentFile = "/run/secrets/atticd";

        settings = {
          listen = "[::]:5580";

          database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";

          storage = {
            type = "s3";
            region = "us-east-1";
            bucket = "attic";
            endpoint = "http://localhost:9000";

            credentials = {
              # sourced from environmentFile via
              # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
            };
          };

          chunking = {
            nar-size-threshold = 65536; # 64 KiB — chunk NARs above this size
            min-size = 16384; # 16 KiB
            avg-size = 65536; # 64 KiB
            max-size = 262144; # 256 KiB
          };

          compression = {
            type = "zstd";
          };

          garbage-collection = {
            interval = "12 hours";
            default-retention-period = "6 months";
          };
        };
      };
    };
}
