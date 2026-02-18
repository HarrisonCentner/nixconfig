{
  flake.modules = {
    homeManager.languages.typst =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          typst
        ];
      };
  };
}
