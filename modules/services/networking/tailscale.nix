{
  flake.modules.nixos.tailscale =
    { pkgs, ... }:
    {
      services.tailscale = {
        enable = true;
        extraUpFlags = [
          "--ssh"
        ];
      };

      ephemeralRoot.persist.directories = [
        "/var/lib/tailscale"
      ];
    };
}
