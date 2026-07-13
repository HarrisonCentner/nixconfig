{
  flake.modules.homeManager.messaging =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [
        vesktop
        signal-desktop
        slack
      ];

      ephemeralRoot.persist.directories = [
        ".config/Signal"
        ".config/Slack"
      ];
      backup.directories = [
        ".config/Signal"
      ];
    };
}
