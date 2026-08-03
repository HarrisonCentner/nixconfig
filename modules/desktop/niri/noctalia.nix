{
  inputs,
  ...
}:
{
  flake.modules.homeManager.noctalia-shell =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      net-privacy-status =
        let
          unwrapped = pkgs.writers.writeHaskellBin "net-privacy-status" {
            libraries = with pkgs.haskellPackages; [
              aeson
              bytestring
              text
              turtle
            ];
          } (builtins.readFile ./net-privacy-status.hs);
        in
        # Plugins run commands via `sh -c`; curl/dig must come from the
        # closure, not the session PATH.
        pkgs.runCommand "net-privacy-status"
          {
            nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
            meta.mainProgram = "net-privacy-status";
          }
          ''
            makeWrapper ${unwrapped}/bin/net-privacy-status $out/bin/net-privacy-status \
              --prefix PATH : ${
                lib.makeBinPath (
                  with pkgs;
                  [
                    curl
                    dnsutils
                  ]
                )
              }
          '';

      net-privacy-plugin =
        pkgs.runCommand "noctalia-plugin-net-privacy"
          {
            nativeBuildInputs = [ config.programs.noctalia.package ];
          }
          ''
            mkdir -p $out/net-privacy
            cat > $out/net-privacy/plugin.toml <<'EOF'
            id = "hcentner/net-privacy"
            name = "Net Privacy"
            # Must sit inside the shell's supported range or the plugin is
            # silently skipped; 14 also loads under nixpkgs' 5.0.0-beta.5.
            plugin_api = 14

            [[widget]]
            id = "status"
            entry = "status.luau"
            EOF
            cp ${
              pkgs.replaceVars ./net-privacy.luau {
                statusCommand = lib.getExe net-privacy-status;
              }
            } $out/net-privacy/status.luau
            noctalia plugins lint $out
          '';
    in
    {
      imports = [ inputs.noctalia.homeModules.default ];

      home.packages = [ net-privacy-status ];

      programs.noctalia = {
        enable = true;
        settings = {
          shell = {
            font_family = "sans-serif";
            time_format = "%-I:%M %p";
            date_format = "%a, %b %d";
            avatar_path = "/home/hcentner/.face";
            telemetry_enabled = false;
            clipboard_enabled = false;

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

          calendar.enabled = true;

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

          plugins = {
            auto_update = false;
            enabled = [ "hcentner/net-privacy" ];
            source = [
              {
                name = "nixconfig";
                kind = "path";
                location = "${net-privacy-plugin}";
                enabled = true;
              }
            ];
          };

          control_center = {
            calendar = {
              show_events_card = true;
              show_week_numbers = true;
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
              format = "%-I:%M %p %a, %b %d";
              vertical_format = "%-I\\n%M\\n%p";
              tooltip_format = "%-I:%M %p %a, %b %d";
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

            net_privacy.type = "hcentner/net-privacy:status";

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
