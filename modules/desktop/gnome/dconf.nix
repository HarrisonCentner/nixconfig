{
  flake.modules.homeManager.desktop-gnome =
    { lib, ... }:
    with lib.hm.gvariant;
    {
      # Helpful commands:
      #    dconf watch /org/gnome/desktop/
      #    dconf dump /org/gnome/desktop/ | dconf2nix

      # Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
      dconf.settings = {
        "app-folders" = {
          folder-children = [
            "System"
            "Utilities"
            "YaST"
            "Pardus"
            "15f41a6d-f9c4-489e-a12c-45add7cc993b"
            "f59196c8-dbd4-4d08-a457-0653c948e4b1"
            "8552c3fa-1d30-4582-80de-7a3023795af5"
            "d0ded591-d3b6-4c3a-afb4-edaa99713959"
            "12a30212-6c59-4ee8-aa6e-09730f50852e"
            "33b52964-d2c1-4700-9813-2cd56ee70124"
            "5bab0406-7fdc-484b-a941-7d93fb570b62"
          ];
        };

        "app-folders/folders/12a30212-6c59-4ee8-aa6e-09730f50852e" = {
          apps = [
            "bottom.desktop"
            "htop.desktop"
            "org.gnome.baobab.desktop"
            "org.gnome.DiskUtility.desktop"
          ];
          name = "system observability";
          translate = false;
        };

        "app-folders/folders/15f41a6d-f9c4-489e-a12c-45add7cc993b" = {
          apps = [
            "base.desktop"
            "draw.desktop"
            "impress.desktop"
            "math.desktop"
            "writer.desktop"
            "startcenter.desktop"
          ];
          name = "Office";
        };

        "app-folders/folders/2d6c18d4-91df-4605-b2ac-e88bf78585c3" = {
          apps = [
            "calc.desktop"
            "draw.desktop"
            "math.desktop"
            "impress.desktop"
            "writer.desktop"
            "startcenter.desktop"
            "base.desktop"
          ];
          name = "Office";
        };

        "app-folders/folders/33b52964-d2c1-4700-9813-2cd56ee70124" = {
          apps = [
            "org.gnome.Console.desktop"
            "xterm.desktop"
            "vim.desktop"
            "gvim.desktop"
          ];
          name = "editors";
          translate = false;
        };

        "app-folders/folders/5bab0406-7fdc-484b-a941-7d93fb570b62" = {
          apps = [
            "org.gnome.Snapshot.desktop"
            "org.gnome.Settings.desktop"
          ];
          name = "other";
          translate = false;
        };

        "app-folders/folders/8552c3fa-1d30-4582-80de-7a3023795af5" = {
          apps = [
            "firefox.desktop"
          ];
          name = "Internet";
        };

        "app-folders/folders/Pardus" = {
          categories = [ "X-Pardus-Apps" ];
          name = "X-Pardus-Apps.directory";
          translate = true;
        };

        "app-folders/folders/System" = {
          apps = [
            "org.gnome.Logs.desktop"
            "org.gnome.SystemMonitor.desktop"
          ];
          name = "X-GNOME-Shell-System.directory";
          translate = true;
        };

        "app-folders/folders/Utilities" = {
          apps = [
            "org.gnome.Decibels.desktop"
            "org.gnome.Connections.desktop"
            "org.gnome.Papers.desktop"
            "org.gnome.font-viewer.desktop"
            "org.gnome.Loupe.desktop"
            "org.gnome.Showtime.desktop"
            "org.gnome.Extensions.desktop"
          ];
          name = "X-GNOME-Shell-Utilities.directory";
          translate = true;
        };

        "app-folders/folders/YaST" = {
          categories = [ "X-SuSE-YaST" ];
          name = "suse-yast.directory";
          translate = true;
        };

        "app-folders/folders/d0ded591-d3b6-4c3a-afb4-edaa99713959" = {
          apps = [
            "chrome-pacgdjiidkfdhilcljkeebfoklekebig-Profile_1.desktop"
            "chrome-ojibjkjikcpjonjjngfkegflhmffeemk-Default.desktop"
          ];
          name = "proton";
          translate = false;
        };

        "background" = {
          primary-color = "#3a4ba0";
          secondary-color = "#2f302f";
        };

        "break-reminders/eyesight" = {
          play-sound = true;
        };

        "break-reminders/movement" = {
          duration-seconds = mkUint32 300;
          interval-seconds = mkUint32 1800;
          play-sound = true;
        };

        "calendar" = {
          show-weekdate = true;
        };

        "input-sources" = {
          sources = [
            (mkTuple [
              "xkb"
              "us+altgr-intl"
            ])
          ];
          xkb-options = [ "caps:swapescape" ];
        };

        "interface" = {
          accent-color = "pink";
          clock-format = "12h";
          clock-show-seconds = false;
          clock-show-weekday = true;
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
          show-battery-percentage = true;
          toolkit-accessibility = false;
        };

        "notifications" = {
          application-children = [
            "gnome-about-panel"
            "org-gnome-console"
            "firefox"
            "slack"
            "gnome-power-panel"
            "com-mitchellh-ghostty"
            "spotify"
          ];
          show-banners = false;
        };

        "notifications/application/1password" = {
          application-id = "1password.desktop";
        };

        "notifications/application/calc" = {
          application-id = "calc.desktop";
        };

        "notifications/application/chromium-browser" = {
          application-id = "chromium-browser.desktop";
        };

        "notifications/application/com-mitchellh-ghostty" = {
          application-id = "com.mitchellh.ghostty.desktop";
        };

        "notifications/application/firefox" = {
          application-id = "firefox.desktop";
        };

        "notifications/application/gnome-about-panel" = {
          application-id = "gnome-about-panel.desktop";
        };

        "notifications/application/gnome-power-panel" = {
          application-id = "gnome-power-panel.desktop";
        };

        "notifications/application/obsidian" = {
          application-id = "obsidian.desktop";
        };

        "notifications/application/org-gnome-baobab" = {
          application-id = "org.gnome.baobab.desktop";
        };

        "notifications/application/org-gnome-clocks" = {
          application-id = "org.gnome.clocks.desktop";
        };

        "notifications/application/org-gnome-console" = {
          application-id = "org.gnome.Console.desktop";
        };

        "notifications/application/org-gnome-nautilus" = {
          application-id = "org.gnome.Nautilus.desktop";
        };

        "notifications/application/org-gnome-showtime" = {
          application-id = "org.gnome.Showtime.desktop";
        };

        "notifications/application/slack" = {
          application-id = "slack.desktop";
        };

        "notifications/application/spotify" = {
          application-id = "spotify.desktop";
        };

        "peripherals/keyboard" = {
          numlock-state = true;
        };

        "peripherals/mouse" = {
          natural-scroll = false;
        };

        "peripherals/touchpad" = {
          speed = 0.452991;
          tap-to-click = false;
          two-finger-scrolling-enabled = true;
        };

        "screensaver" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file:///nix/store/k95b65cjxvwrlc3dq0crd61m1j72n820-simple-blue-2016-02-19/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
          primary-color = "#3a4ba0";
          secondary-color = "#2f302f";
        };

        "search-providers" = {
          sort-order = [
            "org.gnome.Settings.desktop"
            "org.gnome.Contacts.desktop"
            "org.gnome.Nautilus.desktop"
          ];
        };

        "session" = {
          idle-delay = mkUint32 0;
        };

        "sound" = {
          event-sounds = true;
          theme-name = "__custom";
        };

      };
    };
}
