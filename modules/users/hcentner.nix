topLevel@{
  ...
}:
let
  userName = "hcentner";

  homeDirectory = "/home/${userName}";
in
{
  flake = {
    meta.users = {
      hcentner = {
        email = "harrisoncent@protonmail.com";
        name = "Harrison Centner";
        username = userName;
        # key = "0AAF2901E8040715"; # ed25519/0x0AAF2901E8040715
        # keygrip = [
        # ];
        authorizedKeys = [ ];
      };
    };

    modules.nixos.${userName} =
      { pkgs, ... }:
      {
        users.users.${userName} = {
          description = topLevel.config.flake.meta.users.${userName}.name;
          isNormalUser = true;
          createHome = true;
          extraGroups = [
            "networkmanager"
            "tty"
            "wheel"
            "docker"
            "audio"
          ];
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = topLevel.config.flake.meta.users.${userName}.authorizedKeys;
          initialPassword = "hkc";
        };

        nix.settings.trusted-users = [ topLevel.config.flake.meta.users.${userName}.username ];
      };

    modules.homeManager.${userName} = {
      home.sessionPath = [
        "${homeDirectory}/nixconfig"
      ];

      backup = {
        directories = [
          "Documents"
          "Pictures"
          "software"
        ];
        exclude = [
          "software/rome"
        ];
      };
    };

  };
}
