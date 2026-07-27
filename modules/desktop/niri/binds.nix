{
  flake.modules.homeManager.desktop-niri =
    { pkgs, lib, ... }:
    {
      programs.niri.settings = {

        binds = {
          "Mod+Return".action.spawn = "ghostty";
          "Mod+Slash".action.spawn = [
            "noctalia"
            "msg"
            "panel-toggle"
            "launcher"
          ];
          "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

          "Mod+Z".action.spawn = [
            "noctalia"
            "msg"
            "session"
            "lock"
          ];

          "Mod+Q".action.close-window = [ ];
          "Mod+F".action.maximize-column = [ ];
          "Mod+G".action.fullscreen-window = [ ];
          "Mod+Shift+G".action.toggle-windowed-fullscreen = [ ];
          "Mod+Shift+F".action.toggle-window-floating = [ ];
          "Mod+C".action.center-column = [ ];

          # Vim-style focus
          "Mod+H".action.focus-column-left = [ ];
          "Mod+L".action.focus-column-right = [ ];
          "Mod+K".action.focus-window-up = [ ];
          "Mod+J".action.focus-window-down = [ ];

          # Arrow key focus
          "Mod+Left".action.focus-column-left = [ ];
          "Mod+Right".action.focus-column-right = [ ];
          "Mod+Up".action.focus-window-up = [ ];
          "Mod+Down".action.focus-window-down = [ ];

          # Move windows
          "Mod+Shift+H".action.move-column-left = [ ];
          "Mod+Shift+L".action.move-column-right = [ ];
          "Mod+Shift+K".action.move-window-up = [ ];
          "Mod+Shift+J".action.move-window-down = [ ];

          # Workspaces
          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;

          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Mod+Shift+6".action.move-column-to-workspace = 6;
          "Mod+Shift+7".action.move-column-to-workspace = 7;
          "Mod+Shift+8".action.move-column-to-workspace = 8;
          "Mod+Shift+9".action.move-column-to-workspace = 9;

          # Column consume/expel
          "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
          "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

          # Set column width to 50%
          "Mod+D".action.set-column-width = "50%";

          # Resize
          "Mod+Ctrl+H".action.set-column-width = "-5%";
          "Mod+Ctrl+L".action.set-column-width = "+5%";
          "Mod+Ctrl+J".action.set-window-height = "-5%";
          "Mod+Ctrl+K".action.set-window-height = "+5%";

          # Scroll focus
          "Mod+WheelScrollDown".action.focus-column-left = [ ];
          "Mod+WheelScrollUp".action.focus-column-right = [ ];
          "Mod+Ctrl+WheelScrollDown".action.focus-workspace-down = [ ];
          "Mod+Ctrl+WheelScrollUp".action.focus-workspace-up = [ ];

          # Audio
          "XF86AudioRaiseVolume".action.spawn = [
            "wpctl"
            "set-volume"
            "-l"
            "1.4"
            "@DEFAULT_AUDIO_SINK@"
            "5%+"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            "wpctl"
            "set-volume"
            "-l"
            "1.4"
            "@DEFAULT_AUDIO_SINK@"
            "5%-"
          ];
          "XF86AudioMute".action.spawn = [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];

          # Brightness
          "XF86MonBrightnessUp".action.spawn = [
            "brightnessctl"
            "set"
            "5%+"
          ];
          "XF86MonBrightnessDown".action.spawn = [
            "brightnessctl"
            "set"
            "5%-"
          ];

          # Screenshots
          "Mod+Ctrl+S".action.spawn = [
            "sh"
            "-c"
            ''mkdir -p ~/Pictures/Screenshots && ${lib.getExe pkgs.grim} -l 0 - | tee ~/Pictures/Screenshots/"$(date +%Y%m%d-%H%M%S)".png | ${pkgs.wl-clipboard}/bin/wl-copy''
          ];
          "Mod+Shift+S".action.spawn = [
            "sh"
            "-c"
            ''mkdir -p ~/Pictures/Screenshots && ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp} -w 0)" - | tee ~/Pictures/Screenshots/"$(date +%Y%m%d-%H%M%S)".png | ${pkgs.wl-clipboard}/bin/wl-copy''
          ];
          "Mod+Shift+E".action.spawn = [
            "sh"
            "-c"
            "${pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe pkgs.swappy} -f -"
          ];
        };

      };

    };
}
