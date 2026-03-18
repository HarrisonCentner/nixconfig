{
  config,
  ...
}:
{
  flake.modules.nixos."hosts/nixos/microvm-desktop" = {
    imports = with config.flake.modules.nixos; [
      base
      desktop
      microvm-guest
      microvm-guest-qemu

      # Users
      root
      microvm-agent

      # Services
      docker
      ssh
    ];

    microvm = {
      mem = 8192;
      vcpu = 6;

      interfaces = [
        {
          type = "tap";
          id = "vm-desktop";
          mac = "02:00:00:00:00:01";
        }
      ];

      volumes = [
        {
          image = "/var/lib/microvms/desktop/nix-store-overlay.img";
          mountPoint = "/nix/.rw-store";
          size = 8192;
        }
        {
          image = "/var/lib/microvms/desktop/data.img";
          mountPoint = "/data";
          size = 16384;
        }
      ];
    };

    systemd.network = {
      enable = true;
      networks."20-eth0" = {
        matchConfig.MACAddress = "02:00:00:00:00:01";
        networkConfig = {
          Address = "10.0.100.2/30";
          DNS = [ "1.1.1.1" ];
        };
        routes = [ { Gateway = "10.0.100.1"; } ];
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
        desktop
        shell

        # Apps
        browser
      ];
    };
  };
}
