{
  flake.modules.homeManager.shell = { pkgs, ...}: {
    home.packages = with pkgs; [
      nodejs # required for coc-nvim
    ];
    programs = {
      vim = {
        enable = true;
      };
    };
  };
}
