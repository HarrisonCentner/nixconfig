# Test Purpose

This test verifies that the nix-mineral wiring does not break the stack:
+ docker container networking works end to end through NAT (container → bridge → eth1 → second node), which requires IP forwarding to survive nix-mineral's sysctl clamps
+ the boot-time sysctl config contains no forwarding clamp (dockerd re-enabling `ip_forward` at runtime would otherwise mask a regression)
+ `/proc` is mounted without `hidepid` (the compatibility preset's override loses the merge upstream, so it is forced off in our module)
+ `/home` defined as a dedicated filesystem mounts with hardened options but without `bind` (which fails stage-2 activation) or `noexec`
+ hardening is actually active at runtime: yama ptrace scope, `noexec` on `/var`, the kicksecure module blacklist
