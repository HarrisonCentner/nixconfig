{
  _module.args.mkOpSecret =
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
}
