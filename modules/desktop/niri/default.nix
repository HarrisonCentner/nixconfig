{
  blockOutFromScreencast,
  ...
}:
{
  flake.modules.nixos.desktop-niri =
    { pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        useNautilus = false;
      };

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      # Wayland utilities
      environment.systemPackages = with pkgs; [
        grim
        slurp
        wl-clipboard
        swaybg
        swappy
        brightnessctl
      ];

      # Battery status and power management
      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;

      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitchExternalPower = "ignore";
      };

      # Polkit authentication agent
      security.polkit.enable = true;
      systemd.user.services.polkit-gnome-agent = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/lib/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      # File manager with MTP/automount support (Kindle, phones, USB)
      programs.thunar = {
        enable = true;
        plugins = with pkgs; [
          thunar-volman
          thunar-archive-plugin
        ];
      };
      services = {
        gvfs.enable = true;
        udisks2.enable = true;
        tumbler.enable = true;
      };

      # programs.niri configures the portals; the gtk portal backs the
      # gnome one for interfaces it does not implement
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      # Pipewire for audio
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
        jack.enable = true;
      };

      # Login manager
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
      security.pam.services.greetd.enableGnomeKeyring = true;
    };

  flake.modules.homeManager.desktop-niri =
    { pkgs, ... }:
    {
      programs.ghostty.settings.command = "sh -c 'tmux has-session -t main 2>/dev/null && exec tmux new-session -t main \\; new-window || exec tmux new-session -s main'";

      xdg.mimeApps = {
        enable = true;
        defaultApplications."inode/directory" = "thunar.desktop";
      };

      wayland.windowManager.niri = {
        enable = true;
        # units and portals come from the system-level programs.niri
        systemd.enable = false;
        portalPackage = null;
        settings = {
          prefer-no-csd = { };

          _children = blockOutFromScreencast [ "(?i)^thunar$" ];

          input = {
            keyboard = {
              xkb = {
                layout = "us";
                variant = "altgr-intl";
                options = "caps:swapescape,lv3:rwin_switch";
              };
              repeat-rate = 40;
              repeat-delay = 250;
            };

            touchpad.natural-scroll = { };

            mouse = {
              accel-profile = "flat";
            };
          };

          switch-events.lid-close.spawn = [
            "sh"
            "-c"
            "noctalia msg session lock && systemctl suspend"
          ];

          layout = {
            gaps = 5;
            focus-ring = {
              width = 2;
            };
          };

          spawn-at-startup = "noctalia";
        };
      };

      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 900;
            command = "noctalia msg session lock";
          }
          {
            timeout = 1800;
            command = "systemctl suspend";
          }
        ];
      };
    };
}
