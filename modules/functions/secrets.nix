{
  _module.args.mkOpSecret =
    {
      service,
      field,
      owner ? service,
      group ? owner,
      services ? [ service ],
    }:
    {
      reference = "op://nixconfig/${service}/${field}";
      inherit owner group services;
      mode = "0400";
    };
}
