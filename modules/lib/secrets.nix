let
  opnixSecretsDir = "/run/opnix/secrets";
in
{
  _module.args = {
    inherit opnixSecretsDir;

    mkOpSecret =
      {
        service,
        field,
        owner ? service,
        group ? "users",
        services ? [ service ],
      }:
      {
        reference = "op://nixconfig/${service}/${field}";
        inherit owner group services;
        mode = "0400";
      };
  };
}
