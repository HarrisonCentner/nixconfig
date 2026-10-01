{
  blockOutFromScreencast,
  appleColorEmoji,
  repackElectronApp,
  ...
}:
{
  flake.modules.homeManager.messaging =
    { pkgs, ... }:
    let
      appleEmojiTtf = "${appleColorEmoji pkgs}/share/fonts/truetype/AppleColorEmoji.ttf";
      appleEmojiRedirect = pkgs.writeText "slack-apple-emoji.js" ''
        require("electron").app.on("session-created", (session) => {
          session.webRequest.onBeforeRequest(
            { urls: [ "https://*.slack-edge.com/production-standard-emoji-assets/*" ] },
            (details, callback) => {
              const redirectURL = details.url.replace("/google-", "/apple-");
              callback(redirectURL === details.url ? {} : { redirectURL });
            }
          );
        });
      '';
      slack = repackElectronApp pkgs {
        package = pkgs.slack;
        asar = "lib/slack/resources/app.asar";
        packFlags = [
          "--unpack-dir"
          "{node_modules,dist/resources}"
          "--unpack"
          "*-entry-point.bundle.js"
        ];
        extraPatch = ''
          echo >> dist/boot.bundle.cjs
          cat ${appleEmojiRedirect} >> dist/boot.bundle.cjs
        '';
      };
      signal-desktop = repackElectronApp pkgs {
        package = pkgs.signal-desktop;
        asar = "share/signal-desktop/app.asar";
        packFlags = [
          "--unpack"
          "*.node"
        ];
        extraPatch = ''
          substituteInPlace stylesheets/manifest.css \
            --replace-fail "file://${pkgs.noto-fonts-color-emoji}/share/fonts/noto/NotoColorEmoji.ttf" "file://${appleEmojiTtf}"
          substituteInPlace stylesheets/manifest.css sticker-creator/dist/assets/*.css \
            --replace-fail "asset:///optional-fonts/emoji-large.woff2" "file://${appleEmojiTtf}"
          substituteInPlace bundles/main.js \
            --replace-fail "${pkgs.noto-fonts-color-emoji}" "${appleColorEmoji pkgs}"
        '';
      };
      vesktop = repackElectronApp pkgs {
        package = pkgs.vesktop;
        asar = "opt/Vesktop/resources/app.asar";
        packFlags = [
          "--unpack"
          "*.node"
        ];
      };
      protonmail-desktop = repackElectronApp pkgs {
        package = pkgs.protonmail-desktop;
        asar = "share/proton-mail/app.asar";
      };
      protonmail-icon = pkgs.fetchurl {
        name = "proton-mail.svg";
        url = "https://raw.githubusercontent.com/ProtonMail/WebClients/a7c568e1de4e872644789385130aef59c6936a10/applications/mail/src/favicon.svg";
        hash = "sha256-ks+X7lCceeS0YQrY0eD9+1N+T26eB8IzLo+Pv0uV1ME=";
      };
      zoom-us = pkgs.zoom-us.override { gnomeXdgDesktopPortalSupport = true; };
    in
    {
      nixpkgs.config.allowUnfree = true;
      home.packages =
        (with pkgs; [
          # make slack icon appear
          hicolor-icon-theme
        ])
        ++ [
          protonmail-desktop
          slack
          signal-desktop
          vesktop
          zoom-us
        ];

      # Shadows the package's entry, whose icon carries a Linux badge.
      xdg.desktopEntries.proton-mail = {
        name = "Proton Mail";
        genericName = "Email Client";
        exec = "proton-mail %U";
        icon = protonmail-icon;
        categories = [
          "Network"
          "Email"
        ];
        mimeType = [ "x-scheme-handler/mailto" ];
      };

      wayland.windowManager.niri.settings._children = blockOutFromScreencast [
        "(?i)^signal$"
        "(?i)^vesktop$"
      ];

      ephemeralRoot.persist.directories = [
        ".config/Proton Mail"
        ".config/Signal"
        ".config/Slack"
      ];
      backup.directories = [
        ".config/Signal"
      ];
    };
}
