{ inputs, ... }:
{
  flake.modules.nixos.secrets = {
    imports = [ inputs.opnix.nixosModules.default ];

    services.onepassword-secrets = {
      enable = true;
      tokenFile = "/etc/opnix-token";
    };

    ephemeralRoot.persist = {
      files = [ "/etc/opnix-token" ];
      directories = [ "/var/lib/opnix" ];
    };
  };
}
