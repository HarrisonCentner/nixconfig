{
  blockOutFromScreencast,
  appleColorEmoji,
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
      slack = pkgs.slack.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.asar ];
        postInstall = (old.postInstall or "") + ''
          asar extract $out/lib/slack/resources/app.asar $TMPDIR/app
          echo >> $TMPDIR/app/dist/boot.bundle.cjs
          cat ${appleEmojiRedirect} >> $TMPDIR/app/dist/boot.bundle.cjs
          rm -r $out/lib/slack/resources/app.asar $out/lib/slack/resources/app.asar.unpacked
          asar pack $TMPDIR/app $out/lib/slack/resources/app.asar \
            --unpack-dir "{node_modules,dist/resources}" \
            --unpack "*-entry-point.bundle.js"
        '';
      });
      signal-desktop = pkgs.signal-desktop.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.asar ];
        postInstall = (old.postInstall or "") + ''
          asar extract $out/share/signal-desktop/app.asar $TMPDIR/signal
          substituteInPlace $TMPDIR/signal/stylesheets/manifest.css \
            --replace-fail "file://${pkgs.noto-fonts-color-emoji}/share/fonts/noto/NotoColorEmoji.ttf" "file://${appleEmojiTtf}"
          substituteInPlace $TMPDIR/signal/stylesheets/manifest.css $TMPDIR/signal/sticker-creator/dist/assets/*.css \
            --replace-fail "asset:///optional-fonts/emoji-large.woff2" "file://${appleEmojiTtf}"
          substituteInPlace $TMPDIR/signal/bundles/main.js \
            --replace-fail "${pkgs.noto-fonts-color-emoji}" "${appleColorEmoji pkgs}"
          rm -r $out/share/signal-desktop/app.asar $out/share/signal-desktop/app.asar.unpacked
          asar pack $TMPDIR/signal $out/share/signal-desktop/app.asar --unpack "*.node"
        '';
      });
      zoom-us = pkgs.zoom-us.override { gnomeXdgDesktopPortalSupport = true; };
    in
    {
      nixpkgs.config.allowUnfree = true;
      home.packages =
        (with pkgs; [
          # make slack icon appear
          hicolor-icon-theme
          # discord
          vesktop
        ])
        ++ [
          slack
          signal-desktop
          zoom-us
        ];

      programs.niri.settings.window-rules = blockOutFromScreencast [
        "(?i)^signal$"
        "(?i)^vesktop$"
      ];

      ephemeralRoot.persist.directories = [
        ".config/Signal"
        ".config/Slack"
      ];
      backup.directories = [
        ".config/Signal"
      ];
    };
}
