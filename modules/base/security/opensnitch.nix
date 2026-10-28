{
  flake.modules.nixos.security = {
    services.opensnitch = {
      enable = true;
      settings.DefaultAction = "allow";
    };

    ephemeralRoot.persist.directories = [
      "/var/lib/opensnitch"
    ];
  };

  flake.modules.homeManager.security =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      dataDir = "${config.xdg.dataHome}/opensnitch";
      # timeout 0 answers prompts instantly with the default action; the rest
      # are the UI's integer enum indices (allow, "until reboot", sqlite file)
      defaults = pkgs.writeText "opensnitch-ui-settings.conf" (
        lib.generators.toINI { } {
          global = {
            default_action = 1;
            default_duration = 7;
            default_timeout = 0;
            disable_popups = true;
          };
          database = {
            type = 1;
            file = "${dataDir}/events.db";
            purge_oldest = true;
            max_days = 30;
          };
        }
      );
    in
    {
      services.opensnitch-ui.enable = true;
      home.packages = [ pkgs.opensnitch-ui ];

      # the UI rewrites settings.conf, so seed it once instead of linking it
      home.activation.opensnitchUiDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e ${config.xdg.configHome}/opensnitch/settings.conf ]; then
          run mkdir -p ${config.xdg.configHome}/opensnitch ${dataDir}
          run install -m 600 ${defaults} ${config.xdg.configHome}/opensnitch/settings.conf
        fi
      '';

      ephemeralRoot.persist.directories = [
        ".config/opensnitch"
        ".local/share/opensnitch"
      ];
    };
}
