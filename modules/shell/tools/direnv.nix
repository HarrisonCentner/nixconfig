_: {
  flake.modules = {
    homeManager.shell = {
      programs.direnv = {
        enable = true;
        config = {
          global = {
            hide_env_diff = true;
          };
          whitelist = {
            prefix = [ "/home/hcentner/software/rome" ];
          };
        };
        nix-direnv.enable = true;
      };

      ephemeralRoot.persist.directories = [
        ".local/share/direnv"
      ];
    };
  };
}
