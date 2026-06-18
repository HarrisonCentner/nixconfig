{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/portable" = {
    imports =
      with config.flake.modules.nixos;
      with config.flake.nixosModules;
      [
        # Modules
        base
        shell
        portable-disko
        portable-hardware

        # Users
        hcentner

        # Services
        openssh
        tailscale
      ]
      ++ [
        {
          home-manager.users.hcentner = {
            imports = with config.flake.modules.homeManager; [
              # Modules
              base
              shell

              # Users
              hcentner

              # Languages
              nix
            ];
          };
        }
      ];
  };
}
