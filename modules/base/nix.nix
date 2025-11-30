{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      nix = {
        # From https://jackson.dev/post/nix-reasonable-defaults/
        extraOptions = ''
          connect-timeout = 5
          log-lines = 50
          min-free = 128000000
          max-free = 1000000000
          fallback = true
        '';
        optimise.automatic = true;
        settings = {
          trusted-users = [
            "root"
          ];
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          warn-dirty = false;
        };
      };
    };
}
