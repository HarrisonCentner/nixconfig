{ mkOpSecret, writeHaskellBinWrapped, ... }:
let
  user = "hcentner";
  bucket = "harrison-media-library";
  region = "us-east-005";
  prefix = "media";

  mountPoint = "/home/${user}/cloud-media";
  cacheDir = "/home/${user}/.cache/rclone-cloud-media";
in
{
  flake.modules.nixos.cloud-media =
    {
      config,
      pkgs,
      ...
    }:
    let
      secretPaths = config.services.onepassword-secrets.secretPaths;

      cloud-media = writeHaskellBinWrapped pkgs "cloud-media" {
        libraries = with pkgs.haskellPackages; [
          turtle
          directory
          unix
          text
        ];
        env = {
          CLOUD_MEDIA_BUCKET_PATH = "${bucket}/${prefix}";
          CLOUD_MEDIA_ENDPOINT = "s3.${region}.backblazeb2.com";
          CLOUD_MEDIA_REGION = region;
          CLOUD_MEDIA_KEY_ID_FILE = secretPaths.cloudMediaKeyId;
          CLOUD_MEDIA_APP_KEY_FILE = secretPaths.cloudMediaAppKey;
          CLOUD_MEDIA_PASSWORD_FILE = secretPaths.cloudMediaPassword;
          CLOUD_MEDIA_SALT_FILE = secretPaths.cloudMediaSalt;
          CLOUD_MEDIA_MOUNTPOINT = mountPoint;
          CLOUD_MEDIA_CACHE_DIR = cacheDir;
        };
        # fusermount3 is how rclone mounts without privileges
        path = [
          pkgs.rclone
          pkgs.fuse3
        ];
      } (builtins.readFile ./cloud-media.hs);
    in
    {
      services.onepassword-secrets.secrets = {
        cloudMediaKeyId = mkOpSecret {
          service = "cloud-media";
          field = "key_id";
          owner = user;
          services = [ ];
        };
        cloudMediaAppKey = mkOpSecret {
          service = "cloud-media";
          field = "app_key";
          owner = user;
          services = [ ];
        };
        cloudMediaPassword = mkOpSecret {
          service = "cloud-media";
          field = "password";
          owner = user;
          services = [ ];
        };
        cloudMediaSalt = mkOpSecret {
          service = "cloud-media";
          field = "salt";
          owner = user;
          services = [ ];
        };
      };

      environment.systemPackages = [ cloud-media ];

      systemd.user.services.cloud-media-mount = {
        description = "rclone mount of the encrypted cloud media archive";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "notify";
          ExecStart = "${cloud-media}/bin/cloud-media mount";
          ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mountPoint}";
          Restart = "on-failure";
          RestartSec = 10;
        };
      };
    };
}
