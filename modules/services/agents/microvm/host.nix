{
  flake.modules.nixos.microvm-host = {
    systemd.network = {
      enable = true;
      networks = {
        "10-vm-desktop" = {
          matchConfig.Name = "vm-desktop";
          networkConfig = {
            Address = "10.0.100.1/30";
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          };
        };
        "10-vm-headless" = {
          matchConfig.Name = "vm-headless";
          networkConfig = {
            Address = "10.0.100.5/30";
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          };
        };
      };
    };

    networking.nat = {
      enable = true;
      externalInterface = "wlp0s20f3";
      internalInterfaces = [
        "vm-desktop"
        "vm-headless"
      ];
    };
  };
}
