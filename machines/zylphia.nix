{ pkgs, ... }:

# can specify values of fields in Settings in this file
{
  system = {
    stateVersion = 5;

  # keyboard = {
  #   enableKeyMapping = true;  # enable key mapping so that we can use `option` as `control`
  #   remapCapsLockToControl = false;  # remap caps lock to control, useful for emac users
  #   remapCapsLockToEscape  = true;   # remap caps lock to escape, useful for vim users
  #   swapLeftCommandAndLeftAlt = false;
  # };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # is required since we want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = with pkgs; [
    zsh
  ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
  ];
}
