{
  flake.modules.homeManager.shell = { pkgs, ... }:  {
    home.packages = with pkgs; [
      # unix utilities
      duf
      e2fsprogs
      fcp
      htop
      parted
      util-linux
      bottom
      # nix stuff
      direnv
      nix-direnv
      nix-output-monitor
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
      # hardware
      usbutils
      # compression
      xz
    ];
  };
}
