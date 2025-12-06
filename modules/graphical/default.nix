{
  flake.modules.homeManager.graphical =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gnomeExtensions.pop-shell
      ];
    };
}

