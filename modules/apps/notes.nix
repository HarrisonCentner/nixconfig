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

      ephemeralRoot.persist.directories = [
        ".config/obsidian"
      ];
    };
}
