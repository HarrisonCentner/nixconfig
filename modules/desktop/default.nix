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
        gnome-clocks 
        gnome-connections
        gnome-contacts
        gnome-disk-utility 
        gnome-font-viewer 
        gnome-logs 
        gnome-maps 
        gnome-music 
        gnome-photos 
        gnome-screenshot
        gnome-system-monitor 
        gnome-text-editor
        gnome-tour     # tour app
        # gnome-weather (I like the weather app)
      ];
    };
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
      ];
    };
}

