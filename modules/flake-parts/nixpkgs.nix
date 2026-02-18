{
  inputs,
  ...
}:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        nixpkgs.config = {
          allowUnfree = true;
        };
      };
    };
}
