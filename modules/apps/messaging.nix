{
  flake.modules.homeManager.messaging =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        signal-desktop
        slack
      ];
    };
}
