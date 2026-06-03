{ inputs, ... }:
{
  flake.modules.nixos.secrets =
    { lib, ... }:
    {
      imports = [ inputs.agenix.nixosModules.default ];

      age.identityPaths = lib.mkDefault [ "${./dummy-key.txt}" ];
    };
}
