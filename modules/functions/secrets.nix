{
  _module.args.mkOpSecret =
    {
      service,
      field,
      owner ? service,
      services ? [ service ],
    }:
    {
      reference = "op://nixconfig/${service}/${field}";
      inherit owner services;
      group = owner;
      mode = "0400";
    };
}
