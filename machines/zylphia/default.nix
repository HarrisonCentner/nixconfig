{ config, pkgs, username, homeDirectory, ... }:
{
  users.users.${username} = {
    isNormalUser = true;
    home = homeDirectory;
    description = "Primary user";
    extraGroups = [ "wheel" "networkmanager" ];
    group = "wheel";
  };
  networking.nameservers = [ "192.168.1.114" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  imports = [
    ./disko.nix
    ./services.nix
  ];

}
