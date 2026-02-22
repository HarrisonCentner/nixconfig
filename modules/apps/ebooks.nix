{
  flake.modules.nixos.ebooks =
    { pkgs, ... }:
    {
      # allow calibre to mount kindle storage
      services.udisks2.enable = true;
    };

  flake.modules.homeManager.ebooks =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        calibre
      ];
    };
}
