{
  flake.modules = {
    homeManager.shell =
      { pkgs, lib, ... }:
      {
        programs = {
          bottom = {
            enable = true;
          };
        };
        xdg.desktopEntries = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          bottom = {
            name = "bottom";
            noDisplay = true;
          };
        };
      };
  };
}
