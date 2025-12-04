{
  flake.modules = {
    home.vim.coc-settings.lsp = [
    ''
      "clojure": {
        "command": "clojure-lsp",
        "args": [],
        "filetypes": ["clojure", "clojurescript", "edn"],
        "rootPatterns": ["project.clj", "deps.edn", "build.boot", "shadow-cljs.edn"],
        "initializationOptions": {}
      }
    ''
    ];

    homeManager.base =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          clojure
          clojure-lsp
          leiningen
        ];
      };
  };
}

