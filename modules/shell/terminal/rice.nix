{
  flake.modules =
    { pkgs, ... }:
    {
      homeManager.shell = {
        home.packages = with pkgs; [
          weathr
        ];
        programs = {
          fastfetch = {
            enable = true;
          };
        };
      };
    };
}
