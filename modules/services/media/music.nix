{
  flake.modules.nixos.music = {
    services.pipewire.jack.enable = true;

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
