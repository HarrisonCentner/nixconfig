{
  flake.modules = {
    home.vim.coc-settings.lsp = [
    ''
      "haskell": {
        "command": "haskell-language-server-wrapper",
        "args": ["--lsp"],
        "filetypes": ["haskell", "lhaskell"]
      }
    ''
    ];

    homeManager.languages.haskell =
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

