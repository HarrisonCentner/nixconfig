{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/xlthlx" = {
    imports =
      with config.flake.modules.nixos;
      with config.flake.nixosModules;
      [
        # Modules
        base
        shell
        xlthlx-disko
        xlthlx-hardware
        desktop-niri
        intel-graphics

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
              desktop-niri
              noctalia-shell

              # Users
              hcentner

              # Languages
              nix

              # Apps
              editor
            ];
          };
        }
      ];
  };
}
