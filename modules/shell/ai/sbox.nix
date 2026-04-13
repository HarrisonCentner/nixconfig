{
  flake.modules.homeManager.shell = {
    programs.sbox = {
      enable = true;
      allowParent = "off";
      shareHistory = "off";
      bind = {
        "$HOME/.claude" = {};
        "$HOME/.claude.json" = {};
      };
    };
  };
}
