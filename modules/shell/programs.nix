{
  flake.modules.homeManager.shell = { pkgs, ... }:  {
    home.packages = with pkgs; [
      # unix utils
      duf
      tree
      htop
      # nix stuff
      direnv
      nix-direnv
      nix-output-monitor
      # file processing
      file
      jq
      xan
      # unix networking
      dig
      # cli utilities
      bc
    ];
  };
}
