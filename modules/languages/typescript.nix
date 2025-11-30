{
  flake.modules = {
    home.vim.coc-settings.lsp = [];

    homeManager.base =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          nodejs
        ];
      };
  };
}

