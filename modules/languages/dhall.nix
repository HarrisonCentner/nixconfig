{
  flake.modules = {
    homeManager.dhall =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          dhall
          dhall-json
          dhall-lsp-server
        ];
      };
  };
}
