{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        weathr
      ];
      programs = {
        fastfetch = {
          enable = true;
        };
      };
    };
}
