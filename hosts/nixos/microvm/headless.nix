{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/microvm-headless" = {
    imports = with config.flake.modules.nixos; [
      base
      microvm-guest
      microvm-guest-firecracker

      # Users
      root
      microvm-agent

      # Services
      ssh
    ];

    microvm = {
      mem = 8192;
      vcpu = 6;

      interfaces = [
        {
          type = "tap";
          id = "vm-headless";
          mac = "02:00:00:00:00:02";
        }
      ];

      volumes = [
        {
          image = "/var/lib/microvms/headless/nix-store-overlay.img";
          mountPoint = "/nix/.rw-store";
          size = 8192;
        }
        {
          image = "/var/lib/microvms/headless/data.img";
          mountPoint = "/data";
          size = 16384;
        }
      ];
    };

    systemd.network = {
      enable = true;
      networks."20-eth0" = {
        matchConfig.MACAddress = "02:00:00:00:00:02";
        networkConfig = {
          Address = "10.0.100.6/30";
          DNS = [ "1.1.1.1" ];
        };
        routes = [ { Gateway = "10.0.100.5"; } ];
      };
    };

    fileSystems."/home" = {
      device = "/data/home";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/data" ];
    };

    systemd.tmpfiles.rules = [
      "d /data/home/microvm-agent 0700 microvm-agent users -"
    ];

    home-manager.users.microvm-agent = {
      imports = with config.flake.modules.homeManager; [
        base
        shell
      ];
    };
  };
}
