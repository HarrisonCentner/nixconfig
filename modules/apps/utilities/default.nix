{
  flake.modules.homeManager.utilities = { pkgs, ...}: {
    home.packages = with pkgs; [ libreoffice ];
  };
}
