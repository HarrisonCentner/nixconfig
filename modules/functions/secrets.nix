{ lib, ... }:
{
  _module.args.mkSecret = owner: {
    file = lib.mkDefault ../services/security/secrets/dummy.age;
    inherit owner;
  };
}
