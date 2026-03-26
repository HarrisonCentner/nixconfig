{
  flake.modules = {
    nixos.shell =
      { pkgs, ... }:
      {
        users.defaultUserShell = pkgs.zsh;
        programs.zsh.enable = true;
      };

    homeManager.shell = {
      programs = {
        zsh = {
          enable = true;
          shellAliases = {
            nsp = "nix-shell -p $@ --command zsh";
            q = "exit";
          };
          oh-my-zsh = {
            enable = true;
            plugins = [
              "history"
              "git"
            ];
            theme = "eastwood";
          };
        };
      };
    };
  };
}
