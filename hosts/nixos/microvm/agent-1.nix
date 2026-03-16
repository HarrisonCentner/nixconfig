{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/microvm-agent-1" = {
    imports = with config.flake.modules.nixos; [
      base
      desktop
      microvm-guest

      # Users
      root
      microvm-agent

      # Services
      docker
      ssh
    ];

    home-manager.users.microvm-agent = {
      imports = with config.flake.modules.homeManager; [
        base
        desktop
        shell

        # Apps
        browser
      ];
    };
  };
}
