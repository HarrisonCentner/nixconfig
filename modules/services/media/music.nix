{
  flake.modules.nixos.music = {
    # Pipewire for audio
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      jack.enable = true;
      extraConfig.pipewire."10-combine-sink" = {
        "context.modules" = [
          {
            name = "libpipewire-module-combine-stream";
            args = {
              "combine.mode" = "sink";
              "node.name" = "combine_sink";
              "node.description" = "Wired + Bluetooth";
              "combine.latency-compensate" = false;
              "combine.props" = {
                "audio.position" = [
                  "FL"
                  "FR"
                ];
              };
              "stream.props" = { };
              "stream.rules" = [
                {
                  matches = [
                    {
                      "media.class" = "Audio/Sink";
                      "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";
                    }
                    {
                      "media.class" = "Audio/Sink";
                      "node.name" = "~bluez_output.*";
                    }

                  ];
                  actions.create-stream = { };
                }
              ];
            };
          }
        ];
      };
    };

    # scsynth self-sets SCHED_FIFO; without these it falls back to non-RT and xruns
    security.pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "99";
      }
    ];
  };

  flake.modules.homeManager.music =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        supercollider-with-sc3-plugins
        wine # for ableton
      ];
    };
}
