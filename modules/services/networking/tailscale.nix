{
  flake.modules.nixos.tailscale-exit-node.services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-exit-node" ];
  };

  flake.modules.nixos.tailscale =
    { config, lib, ... }:
    let
      tailscale = lib.getExe config.services.tailscale.package;
      services = config.tailscaleServices;
    in
    {
      options.tailscaleServices = lib.mkOption {
        type = lib.types.attrsOf lib.types.port;
        default = { };
      };

      config = lib.mkMerge [
        {
          services.tailscale = {
            enable = true;
            extraUpFlags = [
              "--ssh"
            ];
          };

          ephemeralRoot.persist.directories = [
            "/var/lib/tailscale"
          ];
        }
        # set-config rejects tls-terminated-tcp targets (1.104)
        (lib.mkIf (services != { }) {
          systemd.services.tailscale-services = {
            after = [
              "tailscaled.service"
              "tailscaled-autoconnect.service"
              "tailscaled-set.service"
            ];
            wants = [ "tailscaled.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              ${tailscale} serve reset
              ${lib.concatMapAttrsStringSep "\n" (
                name: port:
                "${tailscale} serve --service=svc:${name} --https=443 --bg --yes http://127.0.0.1:${toString port}"
              ) services}
            '';
          };
        })
      ];
    };
}
