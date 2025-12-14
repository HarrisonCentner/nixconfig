topLevel@{
  inputs,
    ...
}:
let 
  userName = "harrisoncentner";

  homeDirectory = "/Users/${userName}";
in
{
  flake = {
    meta.users = {
      harrisoncentner = {
        email = "harrisoncent@protonmail.com";
        name = "Harrison Centner";
        username = userName;
      };
    };

    modules.darwin.${userName} = { pkgs, ...}: {
      users.users.${userName} = {
        description = topLevel.config.flake.meta.users.${userName}.name;
        createHome = true;
      };
    };
    modules.darwin.base = {
      system.primaryUser = userName;
      users.users.${userName}.home = homeDirectory;
    };
    modules.homeManager.base = {
      home = {
        # homeDirectory = homeDirectory;
        stateVersion = "24.11";
        sessionPath = [
          "${homeDirectory}/nixconfig"
        ];
        sessionVariables = {
          EDITOR = "vim";
        };
        file.".vimrc".source = ../../shell/vimrc.txt;
        file.".vim/coc-settings.json".text = ''
        {
          "suggest.autoTrigger": "always",
            "diagnostic.virtualText": true,
            "languageserver": {
            	"dhall": {
                "command": "dhall-lsp-server",
                "filetypes": [
                  "dhall"
                ]
            }
        }
        '';
      };
      programs.home-manager.enable = true;
    };

  };
}
