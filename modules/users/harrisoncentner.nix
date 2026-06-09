topLevel@{
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

    modules.darwin.${userName} = {
      system.primaryUser = userName;
      users.users.${userName} = {
        description = topLevel.config.flake.meta.users.${userName}.name;
        createHome = true;
        home = homeDirectory;
      };
    };
    modules.homeManager.${userName} = {
      home.sessionPath = [
        "${homeDirectory}/nixconfig"
      ];
    };

  };
}
