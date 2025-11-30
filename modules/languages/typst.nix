{
  flake.modules = {
    home.vim.coc-settings.lsp = [];

    homeManager.languages.typst =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          typst
        ];
      };
  };
}

