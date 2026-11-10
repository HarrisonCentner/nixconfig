{
  flake.modules.nixos.mullvad =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      exitNode = lib.elem config.services.tailscale.useRoutingFeatures [
        "server"
        "both"
      ];
    in
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

        ephemeralRoot.persist.directories = [ "/etc/mullvad-vpn" ];
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
                ${lib.optionalString exitNode ''
                  # tailscaled underlay off the tunnel: direct peer paths instead of DERP
                  meta mark & 0xff0000 == 0x80000 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
                ''}
              }
              # before routing, so strict rp_filter resolves the source via table 52
              chain prerouting {
                type filter hook prerouting priority mangle; policy accept;
                # daddr match leaves forwarded exit-node traffic unmarked, so it takes the tunnel
                iifname "tailscale0" ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
                iifname "tailscale0" ip6 daddr fd7a:115c:a1e0::/48 ct mark set 0x00000f41 meta mark set 0x6d6f6c65
              }
            '';
          };
        };
        # rp_filter ignores packet marks unless this is set
        boot.kernel.sysctl."net.ipv4.conf.all.src_valid_mark" = 1;
      })

      # exit-node replies arrive unmarked on the tunnel and must reach table 52 first.
      # mullvad-daemon adds its rules unprioritised (kernel picks lowest-1), so re-add after it.
      (lib.mkIf (config.services.mullvad-vpn.enable && exitNode) {
        systemd.services.mullvad-tailscale-exit-route = {
          wantedBy = [ "mullvad-daemon.service" ];
          partOf = [ "mullvad-daemon.service" ];
          after = [ "mullvad-daemon.service" ];
          path = [ pkgs.iproute2 ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            for _ in $(seq 60); do
              ip rule | grep -q 'lookup 1836018789' && ip -6 rule | grep -q 'lookup 1836018789' && break
              sleep 1
            done
            while ip rule del to 100.64.0.0/10 lookup 52 2>/dev/null; do :; done
            while ip -6 rule del to fd7a:115c:a1e0::/48 lookup 52 2>/dev/null; do :; done
            ip rule add to 100.64.0.0/10 lookup 52
            ip -6 rule add to fd7a:115c:a1e0::/48 lookup 52
          '';
        };
      })
    ];
}
