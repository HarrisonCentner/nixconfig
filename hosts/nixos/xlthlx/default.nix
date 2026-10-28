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
        shell-host
        xlthlx-disko
        xlthlx-hardware
        desktop-niri
        intel-graphics
        security

        # Users
        hcentner

        # Services
        openssh
        secrets
        tailscale
      ]
      ++ [
        {
          home-manager.users.hcentner = {
            imports = with config.flake.modules.homeManager; [
              # Modules
              base
              shell
              shell-host
              desktop-niri
              noctalia-shell
              security

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
