{ blockOutFromScreencast, ... }:
{
  flake.modules.homeManager.browser =
    { pkgs, lib, ... }:
    let
      chromium-novpn = pkgs.writeShellScriptBin "chromium-novpn" ''
        exec /run/wrappers/bin/mullvad-exclude \
          ${lib.getExe pkgs.ungoogled-chromium} \
          --user-data-dir="$HOME/.local/share/chromium-novpn" \
          --class=chromium-novpn \
          "$@"
      '';
    in
    {
      # programs.firefox.enable = true;
      home.packages = [
        pkgs.ungoogled-chromium
        chromium-novpn
      ];

      xdg.desktopEntries.chromium-novpn = {
        name = "Chromium (no VPN)";
        genericName = "Web Browser";
        exec = "${lib.getExe chromium-novpn} %U";
        icon = "chromium";
        categories = [
          "Network"
          "WebBrowser"
        ];
        settings.StartupWMClass = "chromium-novpn";
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "chromium-browser.desktop";
          "x-scheme-handler/http" = "chromium-browser.desktop";
          "x-scheme-handler/https" = "chromium-browser.desktop";
        };
      };

      # Proton Mail + Calendar PWAs (app-id: chrome-<webapp-id>-<profile>)
      programs.niri.settings.window-rules = blockOutFromScreencast [
        "^chrome-jnpecgipniidlgicjocehkhajgdnjekh-"
        "^chrome-ojibjkjikcpjonjjngfkegflhmffeemk-"
      ];

      ephemeralRoot.persist.directories = [
        ".config/chromium"
      ];
    };
  # Install extensions on ungoogled-chromium
  #
  #  1. Download the latest release from chromium-web-store [here](https://github.com/NeverDecaf/chromium-web-store).
  #  2. Install the extension as a `.crx` (you might need to download the `.tar` extension and unpack it).
  #  3. Go to the chromium web store and add the required extension.
  #
  #  See extended instructions [here](https://avoidthehack.com/manually-install-extensions-ungoogled-chromium).
}
