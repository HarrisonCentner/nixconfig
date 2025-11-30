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

    homeManager.base =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ 
          nixd 
        ];
      };
  };
}
