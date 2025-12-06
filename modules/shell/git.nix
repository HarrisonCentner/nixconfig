{
  flake.modules = {
    homeManager.shell = { config, pkgs, ... }: {
      home.packages = with pkgs; [
        jujutsu
      ];
      programs = {
        git = {
          enable = true;
          settings = {
            user = {
              name = "HarrisonCentner";
              email = "harrisoncent@proton.me";
            };
            commit = {
              gpgsign = true;
              verbose = true;
            };
            core.editor = "vim";
            diff.colorMoved = "default";
            gpg.format = "ssh";
            init.defaultBranch = "master";
            lfs.enable = true;
            merge.conflictstyle = "diff3";
            push.default = "current";
            rerere.enabled = true;
            tag.gpgsign = true;
            tag.sort = "taggerdate";
            user.signingKey = "~/.ssh/id_ed25519";
            delta = {
              enable = true;
              options = {
                navigate = true;
                light = false;
                dark = true;
                side-by-side = false;
                line-numbers = true;
              };
            };
          };
        };
      };
    };
  };
}
