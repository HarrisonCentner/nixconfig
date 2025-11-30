{
  config,
  ...
}:
{
  flake = {
    meta.users = {
      root = {
        authorizedKeys = [
        ];
      };
    };

    modules.nixos.root = {
      users.users.root = {
        openssh.authorizedKeys.keys = config.flake.meta.users.pol.authorizedKeys;
        initialPassword = "hkc";
      };
    };
  };
}
