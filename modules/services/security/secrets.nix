{ opnixSecretsDir, ... }:
{
  flake.modules.nixos.secrets = {
    services.onepassword-secrets = {
      enable = true;
      tokenFile = "/var/lib/opnix/token";
      outputDir = opnixSecretsDir;
    };

    ephemeralRoot.persist.directories = [ "/var/lib/opnix" ];
  };
}
