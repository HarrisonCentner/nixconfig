{
  flake.modules.nixos.power-saving =
    { config, pkgs, ... }:
    {
      # powertop --auto-tune equivalents; powertop itself needs debugfs, which nix-mineral disables
      powerManagement = {
        # powersave pins min freq on passive cpufreq drivers
        cpuFreqGovernor = "schedutil";
        scsiLinkPolicy = "med_power_with_dipm";
      };

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
      '';

      boot = {
        extraModprobeConfig = "options snd_hda_intel power_save=1";
        kernel.sysctl = {
          "kernel.nmi_watchdog" = 0;
          "vm.dirty_writeback_centisecs" = 1500;
        };
      };

      environment.systemPackages = [
        pkgs.lm_sensors
        config.boot.kernelPackages.turbostat
      ];
    };
}
