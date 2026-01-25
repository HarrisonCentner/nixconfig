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
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "iwlwifi" "rtw88_8821au" ];
  hardware.enableRedistributableFirmware = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8812au
  ];

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
