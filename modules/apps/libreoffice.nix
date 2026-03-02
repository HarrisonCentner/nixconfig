{
  flake.modules.homeManager.libreoffice =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        libreoffice
        hledger
        hledger-web
        hledger-iadd
        hledger-fmt
      ];
    };
}
