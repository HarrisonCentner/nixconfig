{
  flake.modules.homeManager.desktop-niri =
    { pkgs, lib, ... }:
    {
      wayland.windowManager.niri.settings.binds = {
        "Mod+Return".spawn = "ghostty";
        "Mod+Slash".spawn = [
          "noctalia"
          "msg"
          "panel-toggle"
          "launcher"
        ];
        "Mod+Shift+Slash".show-hotkey-overlay = { };

        "Mod+Z".spawn = [
          "noctalia"
          "msg"
          "session"
          "lock"
        ];

        "Mod+Q".close-window = { };
        "Mod+F".maximize-column = { };
        "Mod+G".fullscreen-window = { };
        "Mod+Shift+G".toggle-windowed-fullscreen = { };
        "Mod+Shift+F".toggle-window-floating = { };
        "Mod+C".center-column = { };

        # Vim-style focus
        "Mod+H".focus-column-left = { };
        "Mod+L".focus-column-right = { };
        "Mod+K".focus-window-up = { };
        "Mod+J".focus-window-down = { };

        # Arrow key focus
        "Mod+Left".focus-column-left = { };
        "Mod+Right".focus-column-right = { };
        "Mod+Up".focus-window-up = { };
        "Mod+Down".focus-window-down = { };

        # Move windows
        "Mod+Shift+H".move-column-left = { };
        "Mod+Shift+L".move-column-right = { };
        "Mod+Shift+K".move-window-up = { };
        "Mod+Shift+J".move-window-down = { };

        # Workspaces
        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;

        "Mod+Shift+1".move-column-to-workspace = 1;
        "Mod+Shift+2".move-column-to-workspace = 2;
        "Mod+Shift+3".move-column-to-workspace = 3;
        "Mod+Shift+4".move-column-to-workspace = 4;
        "Mod+Shift+5".move-column-to-workspace = 5;
        "Mod+Shift+6".move-column-to-workspace = 6;
        "Mod+Shift+7".move-column-to-workspace = 7;
        "Mod+Shift+8".move-column-to-workspace = 8;
        "Mod+Shift+9".move-column-to-workspace = 9;

        # Column consume/expel
        "Mod+BracketLeft".consume-or-expel-window-left = { };
        "Mod+BracketRight".consume-or-expel-window-right = { };

        # Set column width to 50%
        "Mod+D".set-column-width = "50%";

        # Resize
        "Mod+Ctrl+H".set-column-width = "-5%";
        "Mod+Ctrl+L".set-column-width = "+5%";
        "Mod+Ctrl+J".set-window-height = "-5%";
        "Mod+Ctrl+K".set-window-height = "+5%";

        # Scroll focus
        "Mod+WheelScrollDown".focus-column-left = { };
        "Mod+WheelScrollUp".focus-column-right = { };
        "Mod+Ctrl+WheelScrollDown".focus-workspace-down = { };
        "Mod+Ctrl+WheelScrollUp".focus-workspace-up = { };

        # Audio
        "XF86AudioRaiseVolume".spawn = [
          "wpctl"
          "set-volume"
          "-l"
          "1.4"
          "@DEFAULT_AUDIO_SINK@"
          "5%+"
        ];
        "XF86AudioLowerVolume".spawn = [
          "wpctl"
          "set-volume"
          "-l"
          "1.4"
          "@DEFAULT_AUDIO_SINK@"
          "5%-"
        ];
        "XF86AudioMute".spawn = [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SINK@"
          "toggle"
        ];

        # Brightness
        "XF86MonBrightnessUp".spawn = [
          "brightnessctl"
          "set"
          "5%+"
        ];
        "XF86MonBrightnessDown".spawn = [
          "brightnessctl"
          "set"
          "5%-"
        ];

        # Screenshots
        "Mod+Ctrl+S".spawn = [
          "sh"
          "-c"
          ''mkdir -p ~/Pictures/Screenshots && ${lib.getExe pkgs.grim} -l 0 - | tee ~/Pictures/Screenshots/"$(date +%Y%m%d-%H%M%S)".png | ${pkgs.wl-clipboard}/bin/wl-copy''
        ];
        "Mod+Shift+S".spawn = [
          "sh"
          "-c"
          ''mkdir -p ~/Pictures/Screenshots && ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp} -w 0)" - | tee ~/Pictures/Screenshots/"$(date +%Y%m%d-%H%M%S)".png | ${pkgs.wl-clipboard}/bin/wl-copy''
        ];
        "Mod+Shift+E".spawn = [
          "sh"
          "-c"
          "${pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe pkgs.swappy} -f -"
        ];
      };
    };
}
