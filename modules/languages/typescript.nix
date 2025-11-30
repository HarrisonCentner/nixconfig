{
  flake.modules = {
    home.vim.coc-settings.lsp = [];

    homeManager.languages.typescript =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          nodejs
        ];
      };
  };
}

