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

    modules.nixos.${userName} = { pkgs, ...}: {
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
        openssh.authorizedKeys.keys = topLevel.config.flake.meta.users.${userName}.authorizedKeys;
        initialPassword = "hkc";
      };

      nix.settings.trusted-users = [ topLevel.config.flake.meta.users.${userName}.username ];
    };

    modules.nixos.base = { pkgs, ...}: {
      users.users.${userName} = { 
        isNormalUser = true; 
        extraGroups = [ 
          "wheel" 
          "networkmanager" 
          "docker"
          "tty"
        ]; 
        shell = pkgs.zsh;
      };
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
        file.".vimrc".source = ../../shell/vimrc.txt;
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
