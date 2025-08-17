{ pkgs, ... }:
{
  system = {
    stateVersion = 5;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  programs.zsh.enable = true;
  environment.shells = with pkgs; [
    zsh
  ];

  time.timeZone = "America/Los_Angeles";

  fonts.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
  ];
}
