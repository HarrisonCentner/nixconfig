{
  flake.modules.homeManager.desktop = 
    { pkgs, lib, ... }:
      with lib.hm.gvariant;
    {
      # Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
      dconf.settings = {
        "org/gnome/Console" = {
          audible-bell = false;
          font-scale = 1.0;
          last-window-maximised = false;
          last-window-size = mkTuple [ 1194 1030 ];
        };

        "org/gnome/Snapshot" = {
          is-maximized = false;
          window-height = 640;
          window-width = 800;
        };

        "org/gnome/control-center" = {
          last-panel = "multitasking";
          window-state = mkTuple [ 980 640 false ];
        };

        "org/gnome/desktop/app-folders" = {
          folder-children = [ "System" "Utilities" "YaST" "Pardus" ];
        };

        "org/gnome/desktop/app-folders/folders/Pardus" = {
          categories = [ "X-Pardus-Apps" ];
          name = "X-Pardus-Apps.directory";
          translate = true;
        };

        "org/gnome/desktop/app-folders/folders/System" = {
          apps = [ "org.gnome.baobab.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Logs.desktop" "org.gnome.SystemMonitor.desktop" ];
          name = "X-GNOME-Shell-System.directory";
          translate = true;
        };

        "org/gnome/desktop/app-folders/folders/Utilities" = {
          apps = [ "org.gnome.Decibels.desktop" "org.gnome.Connections.desktop" "org.gnome.Papers.desktop" "org.gnome.font-viewer.desktop" "org.gnome.Loupe.desktop" ];
          name = "X-GNOME-Shell-Utilities.directory";
          translate = true;
        };

        "org/gnome/desktop/app-folders/folders/YaST" = {
          categories = [ "X-SuSE-YaST" ];
          name = "suse-yast.directory";
          translate = true;
        };

        "org/gnome/desktop/break-reminders/eyesight" = {
          play-sound = true;
        };

        "org/gnome/desktop/break-reminders/movement" = {
          duration-seconds = mkUint32 300;
          interval-seconds = mkUint32 1800;
          play-sound = true;
        };

        "org/gnome/desktop/input-sources" = {
          sources = [ (mkTuple [ "xkb" "us" ]) ];
          xkb-options = [ "caps:swapescape" ];
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
          show-battery-percentage = true;
          toolkit-accessibility = false;
        };

        "org/gnome/desktop/notifications" = {
          application-children = [ "gnome-about-panel" "org-gnome-console" "firefox" "slack" "gnome-power-panel" ];
        };

        "org/gnome/desktop/notifications/application/firefox" = {
          application-id = "firefox.desktop";
        };

        "org/gnome/desktop/notifications/application/gnome-about-panel" = {
          application-id = "gnome-about-panel.desktop";
        };

        "org/gnome/desktop/notifications/application/gnome-power-panel" = {
          application-id = "gnome-power-panel.desktop";
        };

        "org/gnome/desktop/notifications/application/org-gnome-console" = {
          application-id = "org.gnome.Console.desktop";
        };

        "org/gnome/desktop/notifications/application/slack" = {
          application-id = "slack.desktop";
        };

        "org/gnome/desktop/peripherals/keyboard" = {
          numlock-state = true;
        };

        "org/gnome/desktop/peripherals/mouse" = {
          natural-scroll = false;
        };

        "org/gnome/desktop/peripherals/touchpad" = {
          speed = 0.45299145299145294;
          tap-to-click = false;
          two-finger-scrolling-enabled = true;
        };

        "org/gnome/desktop/search-providers" = {
          sort-order = [ "org.gnome.Settings.desktop" "org.gnome.Contacts.desktop" "org.gnome.Nautilus.desktop" ];
        };

        "org/gnome/evolution-data-server" = {
          migrated = true;
        };

        "org/gnome/mutter" = {
          edge-tiling = false;
        };

        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "list-view";
          migrated-gtk-settings = true;
        };

        "org/gnome/nautilus/window-state" = {
          initial-size = mkTuple [ 890 550 ];
          initial-size-file-chooser = mkTuple [ 1093 676 ];
        };

        "org/gnome/nm-applet/eap/e958a491-50f3-4ff0-beaf-adb6aefe56d1" = {
          ignore-ca-cert = false;
          ignore-phase2-ca-cert = false;
        };

        "org/gnome/papers" = {
          night-mode = false;
        };

        "org/gnome/papers/default" = {
          annot-color = "yellow";
          continuous = true;
          dual-page = false;
          dual-page-odd-left = false;
          enable-spellchecking = true;
          show-sidebar = true;
          sizing-mode = "automatic";
          window-height = 1168;
        };

        "org/gnome/portal/filechooser/org/chromium/Chromium" = {
          last-folder-path = "/home/hcentner/Downloads";
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-automatic = false;
          night-light-schedule-to = 8.0;
          night-light-temperature = mkUint32 2873;
        };

        "org/gnome/settings-daemon/plugins/housekeeping" = {
          donation-reminder-last-shown = mkInt64 1764905648010415;
        };

        "org/gnome/shell/world-clocks" = {
          locations = [];
        };

        "org/gtk/gtk4/settings/file-chooser" = {
          show-hidden = true;
        };

        "org/gtk/settings/file-chooser" = {
          date-format = "regular";
          location-mode = "path-bar";
          show-hidden = false;
          show-size-column = true;
          show-type-column = true;
          sidebar-width = 167;
          sort-column = "name";
          sort-directories-first = false;
          sort-order = "ascending";
          type-format = "category";
          window-position = mkTuple [ 26 23 ];
          window-size = mkTuple [ 1231 902 ];
        };

      };
    };
}
