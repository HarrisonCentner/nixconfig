{ blockOutFromScreencast, ... }:
{
  flake.modules.homeManager.notes =
    { pkgs, ... }:
    {
      programs.obsidian = {
        enable = true;
        package = pkgs.obsidian.override {
          commandLineArgs = "--password-store=gnome-libsecret";
        };
      };

      wayland.windowManager.niri.settings._children = blockOutFromScreencast [ "(?i)^obsidian$" ];

      ephemeralRoot.persist.directories = [
        ".config/obsidian"
      ];
      backup.directories = [
        ".config/obsidian"
      ];
    };
}
