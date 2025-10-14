{ username, homeDirectory,  ... }: 
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "haskell-miso-cachix.cachix.org-1:m8hN1cvFMJtYib4tj+06xkKt5ABMSGfe8W7s40x1kQ0="
  ];
  nix.settings.trusted-substituters = [
    "https://cache.iog.io"
    "https://haskell-miso-cachix.cachix.org"
  ];
  nix.settings.substituters = [
    "https://cache.iog.io"
  ];

  users.users."${username}".home = "${homeDirectory}";
  nix.settings.trusted-users = [ "${username}" ];
  nix.settings.download-buffer-size = 524288000;
  nix.settings.allow-import-from-derivation = true;
  nix.optimise.automatic = true;
}
