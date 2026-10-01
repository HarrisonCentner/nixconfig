{
  flake.modules.nixos.base = {
    security.sudo-rs.enable = true;
    security.sudo-rs.wheelNeedsPassword = true; # Prompt for password/fingerprint
  };
}
