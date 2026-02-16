{
  flake.modules.homeManager.shell = { pkgs, ... }: {
    home.packages = with pkgs; [
      lazyjj
    ];

    programs = {
      lazygit = {
        enable = true;
        settings = {
          git.overrideGpg = true;
        };
      };
    };
  };
}
