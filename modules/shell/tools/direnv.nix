{ inputs, ... }:
{
  flake.modules = {
    homeManager.shell = {
      imports = [ inputs.direnv-instant.homeModules.direnv-instant ];

      programs = {
        direnv = {
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

        direnv-instant.enable = true;
      };

      ephemeralRoot.persist.directories = [
        ".local/share/direnv"
      ];
    };
  };
}
