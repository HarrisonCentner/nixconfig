{ inputs, ... }:
{
  flake.modules.nixos.secrets = {
    imports = [ inputs.opnix.nixosModules.default ];

    services.onepassword-secrets = {
      enable = true;
      tokenFile = "/var/lib/opnix/token";
    };

    ephemeralRoot.persist.directories = [ "/var/lib/opnix" ];
  };
}
