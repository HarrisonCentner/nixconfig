{
  flake.modules.homeManager.shell = { pkgs, ... }:  {
    home.packages = with pkgs; [
      # unix utils
      duf
      tree
      file
      htop
      # nix stuff
      direnv
      nix-direnv
      nix-output-monitor
      # other
      bc
      jq
      # unix networking
      dig
    ];
  };
}
