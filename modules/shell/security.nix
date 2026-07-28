{ mkOpSecret, ... }:
let
  sopsAgeKeyPath = "/var/lib/opnix/secrets/sopsAgeKey";
in
{
  _module.args.sopsAgeKeyPath = sopsAgeKeyPath;

  flake.modules = {

    nixos.shell = {
      services.onepassword-secrets.secrets.sopsAgeKey = mkOpSecret {
        service = "romeai-harrison.age";
        field = "credential";
        owner = "hcentner";
        services = [ ];
      };
    };

    homeManager.shell =
      { pkgs, ... }:
      {
        home = {
          packages = with pkgs; [
            age
            sops
          ];
          sessionVariables.SOPS_AGE_KEY_FILE = sopsAgeKeyPath;
        };
      };
  };
}
