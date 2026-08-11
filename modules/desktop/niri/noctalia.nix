{
  inputs,
  opnixSecretsDir,
  ...
}:
{
  flake.modules.homeManager.noctalia-shell =
    {
      pkgs,
      ...
    }:
    let
      timeFormat = "%-I:%M %p";
      dateFormat = "%a, %b %d";
      clockFormat = "${timeFormat} ${dateFormat}";
    in
    {
      imports = [ inputs.noctalia.homeModules.default ];


      programs.noctalia = {
        enable = true;
        # screen-time: upstream keeps crediting the focused window while the
        # session is locked. calendar: a timed event ending exactly at midnight
        # is listed on the next day too (exclusive DTEND only handled for
        # all-day). Drop each patch once fixed upstream.
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./screen-time-pause-on-lock.patch
            ./calendar-midnight-end-day-spill.patch
          ];
        });
        settings = {
          shell = {
            font_family = "sans-serif";
            time_format = timeFormat;
            date_format = dateFormat;
            avatar_path = "/home/hcentner/.face";
            telemetry_enabled = false;
            clipboard_enabled = false;
            screen_time_enabled = true;

            screen_corners.enabled = false;

            panel = {
              launcher_placement = "attached";
              clipboard_placement = "attached";
              control_center_placement = "attached";
              wallpaper_placement = "attached";
              session_placement = "attached";
              open_near_click_control_center = true;
            };

            launcher = {
              categories = true;
              show_icons = true;
              app_grid = true;
              sort_by_usage = true;
              auto_paste = "off";
              providers = {
                session.global = true;
                windows.global = true;
              };
            };

            screenshot = {
              pipe_to_command = true;
              pipe_command = "swappy -f -";
            };

            session = {
              grid = true;
              grid_columns = 5;
              show_shortcuts = true;
              actions = [
                {
                  action = "lock";
                  shortcut = "1";
                  countdown_seconds = 10;
                }
                {
                  action = "suspend";
                  shortcut = "2";
                  countdown_seconds = 10;
                }
                {
                  action = "reboot";
                  shortcut = "3";
                  countdown_seconds = 10;
                }
                {
                  action = "logout";
                  shortcut = "4";
                  countdown_seconds = 10;
                }
                {
                  action = "shutdown";
                  shortcut = "5";
                  countdown_seconds = 10;
                }
              ];
            };
          };

          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Catppuccin";
          };

          wallpaper = {
            enabled = true;
            directory = "/home/hcentner/Pictures/Wallpaper";
            fill_mode = "crop";
            transition_duration = 1500;
            edge_smoothness = 0.05;
            automation = {
              enabled = false;
              interval_seconds = 300;
              order = "random";
            };
          };

          lockscreen = {
            enabled = true;
            blur_intensity = 0.0;
            tint_intensity = 0.0;
          };

          notification = {
            enable_daemon = true;
            position = "top_right";
            layer = "overlay";
            background_opacity = 1.0;
          };

          osd = {
            enabled = true;
            position = "top_right";
            background_opacity = 1.0;
            kinds.media = false;
          };

          nightlight = {
            enabled = true;
            temperature_day = 6500;
            temperature_night = 4000;
          };

          location.address = "New York";

          weather = {
            enabled = true;
            # Only "imperial" is honored; example.toml's celsius/fahrenheit is stale.
            unit = "imperial";
            effects = true;
          };

          calendar = {
            enabled = true;
            account.radicale = {
              type = "caldav";
              name = "Calendar";
              provider = "custom";
              server_url = "http://127.0.0.1:5232/";
              username = "hcentner";
              credential_source = "file";
              password_file = "${opnixSecretsDir}/calendarPassword";
            };
          };

          system.monitor = {
            cpu_usage_critical_threshold = 90;
            cpu_temp_critical_threshold = 90;
            ram_pct_critical_threshold = 90;
          };

          dock = {
            enabled = true;
            position = "bottom";
            auto_hide = true;
            # v5 reserves an exclusive zone even while auto-hidden.
            reserve_space = false;
            active_monitor_only = true;
            background_opacity = 1.0;
            show_dots = false;
          };

          desktop_widgets.enabled = false;

          control_center = {
            hidden_tabs = [
              "monitor"
              "notifications"
              "power"
            ];
            calendar = {
              show_events_card = true;
              show_week_numbers = true;
              event_date_format = "%A, %B %e";
              event_time_format = timeFormat;
            };
            shortcuts = [
              { type = "wifi"; }
              { type = "bluetooth"; }
              { type = "notification"; }
              { type = "power_profile"; }
              { type = "nightlight"; }
              { type = "session"; }
            ];
          };

          bar.main = {
            position = "top";
            background_opacity = 0.93;
            capsule = true;
            radius = 12;
            margin_edge = 4;
            margin_ends = 4;
            start = [
              "launcher"
              "clock"
              "cpu_usage"
              "cpu_temp"
              "ram"
              "active_window"
              "media"
            ];
            center = [ "workspaces" ];
            end = [
              "tray"
              "notifications"
              "net_privacy"
              "battery"
              "volume"
              "brightness"
              "control-center"
            ];
          };

          widget = {
            launcher.glyph = "rocket";

            clock = {
              format = clockFormat;
              vertical_format = "%-I\\n%M\\n%p";
              tooltip_format = clockFormat;
            };

            cpu_usage = {
              type = "sysmon";
              stat = "cpu_usage";
              display = "text";
              font_family = "monospace";
            };
            cpu_temp = {
              type = "sysmon";
              stat = "cpu_temp";
              display = "text";
              font_family = "monospace";
            };
            ram = {
              type = "sysmon";
              stat = "ram_used";
              display = "text";
              font_family = "monospace";
            };

            active_window = {
              display = "icon_and_text";
              title_scroll = "on_hover";
              max_length = 145;
            };

            media = {
              artist_first = true;
              title_scroll = "on_hover";
              max_length = 145;
              hide_when_no_media = false;
            };

            tray.drawer = true;

            notifications.hide_when_no_unread = false;

            battery = {
              display_mode = "graphic";
              # Without a label the charging bolt is drawn inside the body in
              # the fill color, where it is invisible.
              show_label = true;
            };

            volume = {
              show_label = false;
              actions.middle = "exec pwvucontrol || pavucontrol";
            };

            brightness.show_label = false;

            workspaces = {
              display = "id";
              hide_when_empty = false;
              labels_only_when_occupied = true;
            };

            "control-center".glyph = "noctalia";
          };
        };
      };
    };
}
