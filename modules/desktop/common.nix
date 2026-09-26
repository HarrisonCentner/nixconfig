{ config, ... }:
let
  inherit (config.flake) modules;
in
{
  flake.modules = {
    nixos = {
      desktop-gnome.imports = [ modules.nixos.desktop ];
      desktop-niri.imports = [ modules.nixos.desktop ];
    };
    homeManager = {
      desktop-gnome.imports = [ modules.homeManager.desktop ];
      desktop-niri.imports = [ modules.homeManager.desktop ];
    };
  };
}
