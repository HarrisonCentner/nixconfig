{ config, ... }:
let userName = config.flake.meta.owner.username;
in {
  flake.modules.nixos.${userName} = {
     users.users.${userName} = { isNormalUser = true; extraGroups = [ "wheel" ]; };
  };
  flake.modules.darwin.${userName} = {
     system.primaryUser = userName; 
  };
  flake.modules.homeManager.${userName} = {
    home = {
      username = userName;
      homeDirectory = lib.mkDefault (
          if pkgs.stdenvNoCC.isDarwin 
            then "/Users/${userName}" 
            else "/home/${userName}"
        );
      home.stateVersion = lib.mkDefault "25.05";
    };
    programs.home-manager.enable = true;
  };
}
