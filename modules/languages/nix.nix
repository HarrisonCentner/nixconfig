{
  flake.modules = {
    home.vim.coc-settings.lsp = [
    ''
      "nix": {
        "command": "nixd",
        "filetypes": ["nix"]
      }
    ''
    ];

    homeManager.nix =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ 
          nixd 
        ];
      };
  };
}
