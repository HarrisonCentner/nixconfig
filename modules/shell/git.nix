{ config, ... }:
{
  flake.modules.homeManager.shell = {
    settings = {

      git = {
        user = {
          email = config.flake.meta.owner.email;
          name = config.flake.meta.owner.name;
        };
        branch.sort = "-committerdate";
        commit.gpgsign = true;
        commit.verbose = true;
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
        ignores = [ "target" "result" ".direnv" ".envrc" ];
        delta = {
          enable = true;
          options = {
            navigate = true;
            light = false;
            dark = true;
            side-by-side = false;
            line-numbers = true;
            features = "zebra-dark";
            zebra-dark = {
              minus-style = "syntax \"#330f0f\"";
              minus-emph-style = "syntax \"#4f1917\"";
              plus-style = "syntax \"#0e2f19\"";
              plus-emph-style = "syntax \"#174525\"";
              map-styles = ''
                bold purple => syntax "#330f29",
                     bold blue => syntax "#271344",
                     bold cyan => syntax "#0d3531",
                     bold yellow => syntax "#222f14"
                       '';
              zero-style = "syntax";
              whitespace-error-style = "#aaaaaa";
            };
          };
        };
      };
    };
  };
};
}
