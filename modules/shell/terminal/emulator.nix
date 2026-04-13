{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
        settings.confirm-close-surface = false;
      };
    };
}
