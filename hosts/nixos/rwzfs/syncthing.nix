{
  flake.nixosModules.rwzfs-syncthing = {
    syncthing.folders.obsidian = {
      id = "obsidian-f927bfd28";
      path = "/home/hcentner/.obsidian";
      devices = [ "iphone-13-pro" ];
    };
  };
}
