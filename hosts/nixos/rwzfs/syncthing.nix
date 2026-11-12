{ renameDesktopEntry, ... }:
{
  flake.nixosModules.rwzfs-syncthing =
    { config, pkgs, ... }:
    {
      syncthing.folders.obsidian = {
        id = "obsidian-f927bfd28";
        path = "/home/hcentner/.obsidian";
        devices = [ "iphone-13-pro" ];
      };

      environment.systemPackages = [
        (renameDesktopEntry pkgs config.services.syncthing.package "Syncthing")
      ];
    };
}
