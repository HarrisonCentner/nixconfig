{
  flake.modules.nixos.desktop = 
    { pkgs, ... }:
    {
      # Exclude Core Apps From Being Installed.
      environment.gnome.excludePackages = with pkgs; [
        # baobab      # disk usage analyzer (I actually like this one)
        cheese      # photo booth
        eog         # image viewer
        epiphany    # web browser
        # evince      # document viewer (currently still use)
        file-roller # archive manager
        geary       # email client
        gedit       # text editor
        seahorse    # password manager
        simple-scan # document scanner
        # totem       # video player (currently still use)
        yelp        # help viewer

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
        gnome-tour     # tour app
        gnome-weather # (displays fahrenheit incorrectly even after updating org.gnome.GWeather4.temperature-unit)
      ];
    };
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
      ];
    };
}

