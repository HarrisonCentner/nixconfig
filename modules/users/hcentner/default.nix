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
        # authorizedKeys = [
        # ];
      };
    };

    modules.nixos.${userName} = {
      users.users.${userName} = {
        description = topLevel.config.flake.meta.users.${userName}.name;
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "networkmanager"
            "tty"
            "wheel"
        ];
        openssh.authorizedKeys.keys = topLevel.config.flake.meta.users.${userName}.authorizedKeys;
        initialPassword = "hkc";
      };

      nix.settings.trusted-users = [ topLevel.config.flake.meta.users.${userName}.username ];
    };

    modules.nixos.base = {
      users.users.${userName} = { isNormalUser = true; extraGroups = [ "wheel" ]; };
    };
    modules.darwin.base = {
      system.primaryUser = userName;
      users.users.${userName}.home = "/home/hcentner";
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
        file."vimrc".source = ../../shell/vimrc.txt;
        file.".vim/coc-settings.json".text = ''
        {
          "suggest.autoTrigger": "always",
            "diagnostic.virtualText": true,
            "languageserver": {
            }
        }
        '';
      };
      programs.home-manager.enable = true;
    };

  };
}
