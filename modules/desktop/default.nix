{
  flake.modules.homeManager.tiling-window-manager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gnomeExtensions.pop-shell
      ];
    };
}

