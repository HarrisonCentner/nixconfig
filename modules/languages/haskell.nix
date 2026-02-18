{
  flake.modules = {
    homeManager.haskell =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          haskellPackages.cabal-install
          haskell.compiler.ghc9102
          haskell-language-server
        ];
      };
  };
}
