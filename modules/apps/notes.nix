{ blockOutFromScreencast, ... }:
{
  flake.modules.homeManager.notes =
    { pkgs, ... }:
    {
      programs.obsidian.enable = true;

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/markdown" = "obsidian.desktop";
        };
      };

      programs.niri.settings.window-rules = blockOutFromScreencast [ "(?i)^obsidian$" ];

      ephemeralRoot.persist.directories = [
        ".config/obsidian"
      ];
      backup.directories = [
        ".config/obsidian"
      ];
    };
}
