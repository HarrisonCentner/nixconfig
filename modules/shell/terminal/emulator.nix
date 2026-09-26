{
  flake.modules = {
    nixos.shell =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.ghostty.terminfo ];
      };

    homeManager.desktop = {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings.confirm-close-surface = false;
      };
    };
  };
}
