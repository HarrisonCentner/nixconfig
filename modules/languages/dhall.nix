{
  flake.modules = {
    home.vim.coc-settings.lsp = [
    ''
      "dhall": {
        "command": "dhall-lsp-server",
        "args": [],
        "filetypes": ["dhall"]
      }
    ''
    ];

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

