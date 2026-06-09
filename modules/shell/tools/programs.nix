{
  flake.modules.homeManager.shell =
    { pkgs, lib, ... }:
    {
      # hide htop from app launcher
      xdg.desktopEntries = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        htop = {
          name = "htop";
          noDisplay = true;
        };
      };

      home.packages =
        with pkgs;
        [
          # unix utilities
          duf
          htop
          # nix stuff
          direnv
          nix-direnv
          nix-output-monitor
          nix-tree
          nurl
          # file processing
          file
          jq
          xan
          # unix networking
          dig
          lsof
          # office utilities
          bc
          programmer-calculator
          # compression
          ouch
          xz
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          e2fsprogs
          parted
          util-linux
          usbutils
        ];
    };
}
