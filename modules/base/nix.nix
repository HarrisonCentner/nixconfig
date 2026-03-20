let
  common =
    { pkgs, ... }:
    {
      # home-manager = {
      #   backupFileExtension = "backup";
      #   useGlobalPkgs = true;
      #   useUserPkgs = true;
      # };
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
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
            "miso-haskell.cachix.org-1:6N2DooyFlZOHUfJtAx1Q09H0P5XXYzoxxQYiwn6W1e8="
          ];
          substituters = [
            "https://cache.iog.io"
            "https://miso-haskell.cachix.org"
          ];
          download-buffer-size = 524288000;
          allow-import-from-derivation = true;
        };
      };
    };
in
{
  flake.modules.nixos.base = common;
  flake.modules.darwin.base = common;
}
