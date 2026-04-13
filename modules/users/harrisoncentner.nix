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

    modules.darwin.${userName} =
      { pkgs, ... }:
      {
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
        stateVersion = "24.11";
        sessionPath = [
          "${homeDirectory}/nixconfig"
        ];
        sessionVariables = {
          EDITOR = "vim";
        };
        file.".vimrc".source = ../../modules/shell/editor/vimrc.txt;
        file.".vim/coc-settings.json".source = ../../modules/shell/editor/coc-settings.json;
      };
      programs.home-manager.enable = true;
    };

  };
}
