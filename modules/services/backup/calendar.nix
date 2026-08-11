{ mkOpSecret, ... }:
{
  flake.modules.nixos.calendar =
    { config, pkgs, ... }:
    let
      htpasswdFile = "/run/radicale/htpasswd";
    in
    {
      services.onepassword-secrets.secrets = {
        radicalePassword = mkOpSecret {
          service = "radicale";
          field = "credential";
        };
        calendarPassword = mkOpSecret {
          service = "radicale";
          field = "credential";
          owner = "hcentner";
          services = [ ];
        };
      };

      services.radicale = {
        enable = true;
        package = pkgs.python3.withPackages (ps: [
          # radicale >=3.5 web plugin API: request_info arg, 4-tuple response
          (ps.radicale-infcloud.overridePythonAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./radicale-infcloud-web-plugin-api.patch ];
          }))
          (ps.toPythonModule pkgs.radicale)
        ]);
        settings = {
          server.hosts = [ "127.0.0.1:5232" ];
          auth = {
            type = "htpasswd";
            htpasswd_filename = htpasswdFile;
            htpasswd_encryption = "plain";
          };
          web.type = "radicale_infcloud";
        };
      };

      systemd.services.radicale.serviceConfig = {
        RuntimeDirectory = "radicale";
        RuntimeDirectoryMode = "0700";
        ExecStartPre = pkgs.writeShellScript "radicale-htpasswd" ''
          umask 077
          printf 'hcentner:%s\n' "$(<${config.services.onepassword-secrets.secretPaths.radicalePassword})" > ${htpasswdFile}
        '';
        TemporaryFileSystem = "/";
        BindReadOnlyPaths = [
          "/nix/store"
          "-/etc/localtime"
          config.services.onepassword-secrets.secretPaths.radicalePassword
        ];
        BindPaths = [
          "/run/radicale"
          "/var/lib/radicale"
        ];
      };

      backup.directories = [ "/var/lib/radicale" ];
      ephemeralRoot.persist.directories = [ "/var/lib/radicale" ];
    };
}
