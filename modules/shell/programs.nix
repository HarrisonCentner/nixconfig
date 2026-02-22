{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # unix utilities
        bottom
        duf
        e2fsprogs
        htop
        parted
        util-linux
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
        # hardware
        usbutils
        # compression
        ouch
        xz
      ];
    };
}
