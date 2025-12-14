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
        initialPassword = "hkc";
      };
    };
  };
}
