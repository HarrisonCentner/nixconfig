{
  flake.modules = {
    homeManager.languages.typescript =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          nodejs
        ];
      };
  };
}
