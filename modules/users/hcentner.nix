topLevel@{
  inputs,
  ...
}:
let
  userName = "hcentner";

  homeDirectory =
    # if inputs.nixpkgs.stdenvNoCC.isDarwin
    #  then "/Users/${userName}"
    "/home/${userName}";
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
          ];
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = topLevel.config.flake.meta.users.${userName}.authorizedKeys;
          initialPassword = "hkc";
        };

        nix.settings.trusted-users = [ topLevel.config.flake.meta.users.${userName}.username ];
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
        file = {
          ".vimrc".source = ../../modules/shell/editor/vimrc.txt;
          ".vim/coc-settings.json".source = ../../modules/shell/editor/coc-settings.json;
        };
      };
      programs.home-manager.enable = true;

      backup.directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "software"
      ];
    };

  };
}
