{
  flake.modules.nixos.shell =
    { pkgs, ... }:
    {
      fonts.fontconfig.enable = true;
    };

  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nerd-fonts.fira-code
      ];
    };
}
