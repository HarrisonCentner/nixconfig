{ inputs, ... }:
{
  flake.modules.nixos.nix-mineral =
    { lib, ... }:
    {
      imports = [ inputs.nix-mineral.nixosModules.nix-mineral ];
      nix-mineral = {
        enable = true;
        preset = [
          "performance"
          "compatibility"
        ];
        settings = {
          # docker, microvm NAT, and tailscale need forwarding
          network.ip-forwarding = true;
          # rngd is killed by its own unit's seccomp filter
          # (jitterentropy-rngd#24); keep the in-kernel source instead
          entropy.jitterentropy = false;
        };
        filesystems = {
          # bind mount breaks stage-2 on dedicated btrfs subvolumes (nix-mineral#11)
          normal."/home".options."bind" = false;
          # compatibility preset sets this but loses to the plain-priority default
          special."/proc".options."hidepid" = lib.mkForce false;
        };
      };
      boot.kernelModules = [ "jitterentropy_rng" ];
    };
}
