# eval-vm-net — host-side networking for the eval-fanout microVM pool.
#
# The eval-fanout daemon (rome repo, dev/ci/eval-fanout) drives cloud-hypervisor
# directly: it boots a warm base on `tap-eval-base`, snapshots it, and restores
# N clones each on its own `tap-eval-<i>` (the daemon opens those taps itself via
# CAP_NET_ADMIN; cloud-hypervisor opens the base tap). This module owns the
# HOST side of those taps: the gateway address the guest routes to, plus egress.
#
# It is the analogue of `microvmLib.mkHostConfig` (modules/functions/microvm.nix)
# for the qwfwq VMs, with three differences that matter:
#
#   1. The taps are created DYNAMICALLY by the daemon/CH (not declared here), so
#      we match them by name glob (`tap-eval-*`, which also covers
#      `tap-eval-base`) and `ConfigureWithoutCarrier` so the address is up before
#      a guest attaches.
#
#   2. NAT is keyed on the SUBNET (`internalIPs`), not on interface names — the
#      per-clone tap names aren't known ahead of time.
#
#   3. ⚠️ CONCURRENCY=1 ASSUMPTION. Every clone is restored from ONE snapshot, so
#      they all share the FROZEN guest IP/MAC (10.177.0.2 / 02:00:00:00:00:01).
#      Two clones up at once would both want host gateway 10.177.0.1 and present
#      the same guest IP — an address/conntrack conflict. At concurrency=1 only
#      one eval tap is up at a time (the base is discarded before clones run, and
#      clones run sequentially), so a single shared /30 is correct. Scaling N>1
#      needs a per-clone network namespace (one isolated 10.177.0.0/30 each) — a
#      future `eval-vm-net@<i>.service`; out of scope for the naive v1 that pairs
#      with the Naive MemoryPolicy.
#
# Addressing MUST agree with the eval guest (rome dev/ci/eval-fanout/nix/vm.nix):
# host/gateway 10.177.0.1, guest 10.177.0.2, and the guest's `llmEnv` points at
# http://10.177.0.1:<proxyPort> (the host-side LLM forward proxy — a SEPARATE
# service that binds this gateway IP and injects the real provider key; not this
# module's job). With that proxy, guests need little/no direct internet egress;
# the masquerade below is the belt-and-suspenders direct-egress path (and the
# seat for the eventual egress allowlist).
{ ... }:
{
  flake.modules.nixos.eval-vm-net =
    { lib, ... }:
    let
      # Host-specific external NIC (matches microvmLib.mkHostConfig on rwzfs).
      externalInterface = "wlp0s20f3";
      # The /30 point-to-point eval link. host=.1 (gateway), guest=.2.
      prefixLength = 30;
      hostAddress = "10.177.0.1";
      evalSubnet = "10.177.0.0/${toString prefixLength}";
    in
    {
      # Bring up + address every eval tap as it appears. One shared /30 is
      # correct only because at most one eval tap is up at a time (see the
      # CONCURRENCY=1 note in the header).
      systemd.network = {
        enable = lib.mkDefault true;
        networks."40-eval-tap" = {
          # Glob covers both `tap-eval-base` and the per-clone `tap-eval-<i>`.
          matchConfig.Name = "tap-eval-*";
          address = [ "${hostAddress}/${toString prefixLength}" ];
          networkConfig = {
            # The host is the guests' router out to the world.
            IPv4Forwarding = true;
            # Taps have no carrier until a guest's virtio-net attaches; assign
            # the gateway address anyway so it's ready at guest boot/restore.
            ConfigureWithoutCarrier = true;
            # The host is the router, never a client of the guest: take no
            # address, RA, route or v6 LL FROM the guest.
            DHCP = "no";
            IPv6AcceptRA = false;
            LinkLocalAddressing = "no";
            DefaultRouteOnDevice = false;
          };
          # Don't block `systemd-networkd-wait-online` on these transient taps.
          linkConfig.RequiredForOnline = "no";
        };
      };

      # NetworkManager owns the host NICs (wlp0s20f3); keep it off the eval taps
      # so it can't pick up a guest-advertised default route either.
      networking.networkmanager.unmanaged = [ "interface-name:tap-eval-*" ];

      # Masquerade the eval subnet out the external NIC. `internalIPs` (subnet)
      # rather than `internalInterfaces` because the clone tap names are dynamic.
      # mkDefault on enable/externalInterface so this COMPOSES with mkHostConfig's
      # NAT (same external NIC) instead of conflicting — internalIPs is additive.
      networking.nat = {
        enable = lib.mkDefault true;
        externalInterface = lib.mkDefault externalInterface;
        internalIPs = [ evalSubnet ];
      };
    };
}
