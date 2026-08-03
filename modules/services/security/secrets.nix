{ opnixSecretsDir, writeHaskellBinWrapped, ... }:
{
  flake.modules.nixos.secrets =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      manifest = pkgs.writeText "opnix-restore-manifest.json" (
        builtins.toJSON (
          lib.mapAttrsToList (name: secret: {
            inherit name;
            path = config.services.onepassword-secrets.secretPaths.${name};
            inherit (secret)
              reference
              owner
              group
              mode
              services
              ;
          }) config.services.onepassword-secrets.secrets
        )
      );

      opnix-restore = writeHaskellBinWrapped pkgs "opnix-restore" {
        libraries = with pkgs.haskellPackages; [
          aeson
          directory
          text
          turtle
        ];
        env.OPNIX_RESTORE_MANIFEST = manifest;
        path = [ pkgs._1password-cli ];
      } (builtins.readFile ./opnix-restore.hs);
    in
    {
      services.onepassword-secrets = {
        enable = true;
        tokenFile = "/var/lib/opnix/token";
        outputDir = opnixSecretsDir;
      };

      environment.systemPackages = [ opnix-restore ];

      ephemeralRoot.persist.directories = [ "/var/lib/opnix" ];
    };
}
