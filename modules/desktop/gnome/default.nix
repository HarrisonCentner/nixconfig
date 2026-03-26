{
  flake.modules.nixos.desktop-gnome =
    { pkgs, lib, ... }:
    {

      # Disable accessibility features
      services = {
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
        gnome.at-spi2-core.enable = lib.mkForce false;
        speechd.enable = false;
        xserver.enable = true;
      };

      # Exclude Core Apps From Being Installed.
      environment.gnome.excludePackages = with pkgs; [
        # baobab      # disk usage analyzer (I actually like this one)
        cheese # photo booth
        eog # image viewer
        epiphany # web browser
        # evince      # document viewer (currently still use)
        file-roller # archive manager
        geary # email client
        gedit # text editor
        orca # gnome screen reader
        seahorse # password manager
        simple-scan # document scanner
        # totem       # video player (currently still use)
        yelp # help viewer

        # these should be self explanatory
        gnome-calculator
        gnome-calendar
        gnome-characters
        # gnome-clocks (I use the timer and stopwatch)
        gnome-connections
        gnome-contacts
        # gnome-disk-utility (I like this one)
        gnome-font-viewer
        gnome-logs
        gnome-maps
        gnome-music
        gnome-photos
        gnome-screenshot
        gnome-system-monitor
        gnome-text-editor
        gnome-tour # tour app
        gnome-weather # (displays fahrenheit incorrectly even after updating org.gnome.GWeather4.temperature-unit)
      ];
    };
  flake.modules.homeManager.desktop-gnome =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # gnome won't let me completely control my screen brightness
        brightnessctl
      ];
    };
}
