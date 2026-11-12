{ repackElectronApp, ... }:
{
  flake.modules.homeManager.design =
    { pkgs, ... }:
    let
      pname = "paper-desktop";
      version = "0.5.19";
      contents = repackElectronApp pkgs {
        package = pkgs.appimageTools.extract {
          inherit pname version;
          # Upstream URL is unversioned: the hash breaks on every release.
          src = pkgs.fetchurl {
            name = "${pname}-${version}-x86_64.AppImage";
            url = "https://download.paper.design/linux/appImage/x64";
            hash = "sha256-YKZUYnYHCJ8ARLLPjEY20bAZ2Qdx0PrsrteDdLJa4Es=";
          };
        };
        asar = "resources/app.asar";
        packFlags = [
          "--unpack-dir"
          "dist/cli-bin"
        ];
      };
      paper-desktop = pkgs.appimageTools.wrapAppImage {
        inherit pname version;
        src = contents;
        extraInstallCommands = ''
          install -Dm444 ${contents}/paper-desktop.desktop -t $out/share/applications
          substituteInPlace $out/share/applications/paper-desktop.desktop \
            --replace-fail "Exec=AppRun" "Exec=paper-desktop"
          cp -r ${contents}/usr/share/icons $out/share
        '';
      };
    in
    {
      home.packages = [ paper-desktop ];

      ephemeralRoot.persist.directories = [
        ".config/Paper"
      ];
    };
}
