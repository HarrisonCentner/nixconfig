{ blockOutFromScreencast, ... }:
{
  flake.modules.homeManager.browser =
    { pkgs, lib, ... }:
    let
      mkChromiumApp =
        name: url:
        pkgs.writeShellApplication {
          inherit name;
          text = ''
            exec ${lib.getExe pkgs.ungoogled-chromium} \
              --profile-directory=Default \
              --app=${lib.escapeShellArg url} \
              "$@"
          '';
        };

      chromium-novpn = pkgs.writeShellScriptBin "chromium-novpn" ''
        exec /run/wrappers/bin/mullvad-exclude \
          ${lib.getExe pkgs.ungoogled-chromium} \
          --user-data-dir="$HOME/.local/share/chromium-novpn" \
          --class=chromium-novpn \
          "$@"
      '';

      proton-mail = mkChromiumApp "proton-mail" "https://mail.proton.me/";
      tailscale-ui = mkChromiumApp "tailscale-ui" "http://100.100.100.100/";

      proton-mail-icon = pkgs.fetchurl {
        name = "proton-mail.svg";
        url = "https://raw.githubusercontent.com/ProtonMail/WebClients/a7c568e1de4e872644789385130aef59c6936a10/applications/mail/src/favicon.svg";
        hash = "sha256-ks+X7lCceeS0YQrY0eD9+1N+T26eB8IzLo+Pv0uV1ME=";
      };
      tailscale-icon = pkgs.fetchurl {
        name = "tailscale.svg";
        url = "https://raw.githubusercontent.com/tailscale/tailscale/53a0d659afa51835dd7a9283873cca44261454f8/client/systray/tailscale.svg";
        hash = "sha256-PjxdnMu1pgIfeTctGkiqQiboDgha9RQe354K03/qoNg=";
      };
    in
    {
      # programs.firefox.enable = true;
      home.packages = [
        pkgs.ungoogled-chromium
        chromium-novpn
        proton-mail
        tailscale-ui
      ];

      xdg.desktopEntries = {
        chromium-novpn = {
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

        # chromium derives native Wayland app IDs from the URL and profile;
        # matching the desktop filename gives deterministic icon association
        "chrome-mail.proton.me__-Default" = {
          name = "Proton Mail";
          genericName = "Email Client";
          exec = lib.getExe proton-mail;
          icon = proton-mail-icon;
          categories = [
            "Network"
            "Email"
          ];
        };

        "chrome-100.100.100.100__-Default" = {
          name = "Tailscale";
          genericName = "VPN Client";
          exec = lib.getExe tailscale-ui;
          icon = tailscale-icon;
          categories = [
            "Network"
          ];
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "chromium-browser.desktop";
          "x-scheme-handler/http" = "chromium-browser.desktop";
          "x-scheme-handler/https" = "chromium-browser.desktop";
        };
      };

      # keep private application windows out of screencasts
      wayland.windowManager.niri.settings._children = blockOutFromScreencast [
        "^chrome-mail\\.proton\\.me__-Default$"
        "^chrome-100\\.100\\.100\\.100__-Default$"
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
