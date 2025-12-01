{ config, pkgs, lib, ... }:
let 
  userName = config.flake.meta.owner.username;
  homeDirectory = lib.mkDefault (
        if pkgs.stdenvNoCC.isDarwin 
          then "/Users/${userName}" 
          else "/home/${userName}"
      );
in 
{
  flake.modules.nixos.${userName} = {
     users.users.${userName} = { isNormalUser = true; extraGroups = [ "wheel" ]; };
  };
  flake.modules.darwin.${userName} = {
     system.primaryUser = userName; 
  };
  flake.modules.homeManager.${userName} = {
    home = {
      homeDirectory = homeDirectory;
      stateVersion = lib.mkDefault "24.11";
      sessionPath = [
        "${homeDirectory}/nixconfig"
      ];
      sessionVariables = {
        EDITOR = "vim";
      };
      file."vimrc".text = builtins.readFile ../shell/vimrc.txt;
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
}
