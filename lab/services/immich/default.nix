{ config, lib, ... }:
let
  cfg = config.homelab.services.immich;
  homelab = config.homelab;
in
{
  options.homelab.services.immich = {
    enable = lib.mkEnableOption "Self-hosted photo and video management solution";
    user = lib.mkOption {
      default = config.homelab.user;
      type = lib.types.str;
      description = ''
        User to run the Immich container as
      '';
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/immich"; };
    url = lib.mkOption {
      type = lib.types.str;
      default = "photos.${homelab.baseDomain}";
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];
    services.immich = {
      enable = true;
      port = 2283;
      host = "0.0.0.0";
      mediaLocation = "${cfg.mediaDir}";
      openFirewall = true;
    };
  };

}
