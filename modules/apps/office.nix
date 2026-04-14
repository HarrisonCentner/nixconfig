{
  # tools for standard office tasks
  flake.modules.homeManager.office =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        sioyek
        libreoffice
        hledger
        hledger-web
        hledger-iadd
        hledger-fmt
      ];

      ephemeralRoot.persist.directories = [
        ".config/libreoffice"
        ".config/sioyek"
      ];
    };
}
