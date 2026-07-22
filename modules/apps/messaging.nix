{ blockOutFromScreencast, ... }:
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

      programs.niri.settings.window-rules = blockOutFromScreencast [
        "(?i)^signal$"
        "(?i)^vesktop$"
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
