{
  flake.modules.nixos.shell = { pkgs, ... }:  {
    fonts.packages = with pkgs; [
      nerd-fonts
    ];
  };
}
