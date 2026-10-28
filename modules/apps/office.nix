{
  # tools for standard office tasks
  flake.modules.homeManager.office =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        sioyek
        libreoffice
        xournalpp
        hledger
        hledger-web
        hledger-iadd
        hledger-fmt
      ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = "sioyek.desktop";
        };
      };

      ephemeralRoot.persist.directories = [
        ".config/libreoffice"
        ".config/sioyek"
        ".config/xournalpp"
      ];
    };
}
