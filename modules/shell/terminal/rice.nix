{
  flake.modules.homeManager.shell-host =
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
