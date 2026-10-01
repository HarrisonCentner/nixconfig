{
  flake.modules.homeManager.airplay =
    { pkgs, lib, ... }:
    let
      gst = pkgs.gst_all_1;
      gstPlugins = [
        gst.gst-plugins-base
        gst.gst-plugins-good
        gst.gst-plugins-bad
        gst.gst-plugins-ugly
        gst.gst-libav
        pkgs.pipewire
      ];
      doubletake = pkgs.buildGoModule {
        pname = "doubletake";
        version = "0.4.0-unstable-2026-08-24";
        src = pkgs.fetchFromGitHub {
          owner = "omarroth";
          repo = "doubletake";
          rev = "ae067228d76df011375164814b729932ed55ca2f";
          hash = "sha256-VbB4fue5xROFhxFaZ5frjB+NLpundGQtKK3/GvWkhQg=";
        };
        vendorHash = "sha256-cgvY9MVGe8I3g3Ni2sGucTY6YCyPJ2YnoxxUaYfl1E4=";
        patches = [ ./wayland-capture.patch ];
        subPackages = [
          "cmd/doubletake"
          "cmd/doubletake-ctl"
          "cmd/doubletake-test-receiver"
        ];
        nativeBuildInputs = [
          pkgs.installShellFiles
          pkgs.makeWrapper
        ];
        postInstall = ''
          installManPage man/man1/*.1
          for bin in $out/bin/*; do
            wrapProgram $bin \
              --prefix PATH : ${
                lib.makeBinPath [
                  gst.gstreamer
                  pkgs.pulseaudio
                  pkgs.xrandr
                ]
              } \
              --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${
                lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins
              }
          done
        '';
      };
    in
    {
      home.packages = [ doubletake ];
    };
}
