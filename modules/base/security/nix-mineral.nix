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
        kernel-modules.enable = true;
        settings = {
          # docker, microvm NAT, and tailscale need forwarding
          network.ip-forwarding = true;
          # rngd is killed by its own unit's seccomp filter
          # (jitterentropy-rngd#24); keep the in-kernel source instead
          entropy.jitterentropy = false;
          # keep boot logs visible; recon benefit not worth lost diagnostics
          debug.quiet-boot = false;
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

  # microvm guests: no desktop hardware to preserve, access survives
  # lock-root via microvm-agent (wheel)
  flake.modules.nixos.nix-mineral-strict = {
    imports = [ inputs.nix-mineral.nixosModules.nix-mineral ];
    nix-mineral = {
      enable = true;
      preset = [ "maximum" ];
      # guests boot direct-kernel with no /boot mount to harden
      filesystems.normal."/boot".enable = false;
      settings = {
        # rngd is killed by its own unit's seccomp filter
        # (jitterentropy-rngd#24); keep the in-kernel source instead
        entropy.jitterentropy = false;
        # the guest console is the only diagnostics channel
        debug.quiet-boot = false;
      };
    };
    boot.kernelModules = [ "jitterentropy_rng" ];
  };
}
