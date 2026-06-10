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
        # docker, microvm NAT, and tailscale need forwarding
        settings.network.ip-forwarding = true;
        filesystems = {
          # bind mount breaks stage-2 on dedicated btrfs subvolumes (nix-mineral#11)
          normal."/home".options."bind" = false;
          # compatibility preset sets this but loses to the plain-priority default
          special."/proc".options."hidepid" = lib.mkForce false;
        };
      };
    };
}
