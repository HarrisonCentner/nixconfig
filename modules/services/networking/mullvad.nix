{
  flake.modules.nixos.mullvad =
    { config, lib, ... }:
    lib.mkMerge [
      {
        services.mullvad-vpn = {
          enable = true;
          # setuid wrapper; required for mullvad-exclude / GUI split tunneling
          enableExcludeWrapper = true;
        };

        # Otherwise NetworkManager adopts the daemon-owned tunnel as an external
        # connection, and any UI offering "disconnect" tears it down while the
        # kill switch keeps blocking — no tunnel, no traffic.
        networking.networkmanager.unmanaged = [ "interface-name:wg*-mullvad" ];
      }

      # Make mullvad work with tailscale. See https://mullvad.net/en/help/split-tunneling-with-linux-advanced
      # ct mark 0xf41 passes its firewall, meta mark 0x6d6f6c65 skips 5209.
      (lib.mkIf (config.services.mullvad-vpn.enable && config.services.tailscale.enable) {
        networking.nftables = {
          enable = true;
          tables.mullvad-tailscale = {
            family = "inet";
            content = ''
              chain output {
                type route hook output priority -100; policy accept;
                ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
                ip6 daddr fd7a:115c:a1e0::/48 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
              }
              # before routing, so strict rp_filter resolves the source via table 52
              chain prerouting {
                type filter hook prerouting priority mangle; policy accept;
                iifname "tailscale0" ct mark set 0x00000f41 meta mark set 0x6d6f6c65
              }
            '';
          };
        };
        # rp_filter ignores packet marks unless this is set
        boot.kernel.sysctl."net.ipv4.conf.all.src_valid_mark" = 1;
      })
    ];
}
