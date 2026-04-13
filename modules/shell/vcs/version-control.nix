{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        jujutsu
      ];

      programs = {
        jujutsu = {
          enable = true;
          settings = {
            user = {
              name = "HarrisonCentner";
              email = "harrisoncent@proton.me";
            };
            revset-aliases."immutable_heads()" = "none()";
          };
        };

        lazygit = {
          enable = true;
          settings = {
            git.overrideGpg = true;
          };
        };

        git = {
          enable = true;
          lfs.enable = true;
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
            merge.conflictstyle = "diff3";
            push.default = "current";
            rerere.enabled = true;
            tag.gpgsign = true;
            tag.sort = "taggerdate";
            user.signingKey = "~/.ssh/id_ed25519";
            filter.lfs = {
              clean = "git-lfs clean -- %f";
              smudge = "git-lfs smudge -- %f";
              process = "git-lfs filter-process";
            };
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
}
