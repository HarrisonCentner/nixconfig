{
  inputs,
  ...
}:
{
  flake.modules.nixos.desktop-niri =
    { pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable.overrideAttrs {
          doCheck = false;
        };
      };

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

      # Portal for file picker, screen sharing, etc.
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
        config.niri = {
          default = [
            "gtk"
            "gnome"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        };
      };

      # Pipewire for audio
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
      };

      # Login manager
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };

  flake.modules.homeManager.desktop-niri = {
    programs.ghostty.settings.command = "sh -c 'tmux has-session -t main 2>/dev/null && exec tmux new-session -t main \\; new-window || exec tmux new-session -s main'";

    programs.niri.settings = {
      prefer-no-csd = true;

      input = {
        keyboard = {
          xkb = {
            layout = "us";
            variant = "altgr-intl";
            options = "caps:swapescape";
          };
          repeat-rate = 40;
          repeat-delay = 250;
        };

        touchpad = {
          natural-scroll = true;
          tap = true;
        };

        mouse = {
          accel-profile = "flat";
        };
      };

      switch-events.lid-close.action.spawn = [
        "sh"
        "-c"
        "qs -c noctalia-shell ipc call lockScreen lock && systemctl suspend"
      ];

      layout = {
        gaps = 5;
        focus-ring = {
          width = 2;
        };
      };

      spawn-at-startup = [
        { command = [ "noctalia-shell" ]; }
      ];
    };

    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 900;
          command = "qs -c noctalia-shell ipc call lockScreen lock";
        }
        {
          timeout = 1800;
          command = "systemctl suspend";
        }
      ];
    };
  };
}
