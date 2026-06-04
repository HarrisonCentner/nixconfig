{
  flake.modules = {
    nixos.shell =
      { pkgs, ... }:
      {
        users.defaultUserShell = pkgs.zsh;
        programs.zsh.enable = true;
      };

    homeManager.shell =
      { pkgs, lib, ... }:
      {
        programs = {
          zsh = {
            enable = true;
            shellAliases = {
              nsp = "nix-shell -p $@ --command zsh";
              open = lib.mkIf pkgs.stdenv.isLinux "xdg-open";
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

        ephemeralRoot.persist = {
          directories = [
            ".local/share/oh-my-zsh"
          ];
          files = [
            ".zsh_history"
          ];
        };
      };
  };
}
