{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/microvm-agent-1" = {
    imports =
      with config.flake.modules.nixos;
      [
        base
        microvm-guest

        # Users
        root
        microvm-agent

        # Services
        ssh
      ];

    home-manager.users.microvm-agent = {
      imports = with config.flake.modules.homeManager; [
        base
        shell
      ];
    };
  };
}
