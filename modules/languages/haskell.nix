{
  flake.modules = {
    homeManager.haskell =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          haskellPackages.cabal-install
          haskell.compiler.ghc912
          haskell-language-server
        ];
      };
  };
}
