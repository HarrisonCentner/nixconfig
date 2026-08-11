{
  flake.modules.nixos.blocky = {
    key = "nixconfig.modules.services.networking.blocky";
    imports = [
      (
        { lib, ... }:
        {
          services.blocky = {
            enable = true;
            settings = {
              ports = {
                # Bind to 127.0.0.1 specifically; systemd-resolved already owns
                # 127.0.0.53:53 and 127.0.0.54:53, so INADDR_ANY (the module
                # default of just "53") would collide.
                dns = "127.0.0.1:53";
                http = 4000;
                https = 443;
              };
              log = {
                level = "warning";
                privacy = true;
              };
              upstreams.groups.default = lib.mkDefault [
                "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
              ];
              # For initially solving DoH/DoT Requests when no system Resolver is available.
              bootstrapDns = lib.mkDefault {
                upstream = "https://one.one.one.one/dns-query";
                ips = [
                  "1.1.1.1"
                  "1.0.0.1"
                ];
              };
              caching = {
                minTime = "5m";
                maxTime = "30m";
                prefetching = true;
                exclude = [
                  "/.*\.lan$/"
                  "/.*\.local$/"
                ];
              };
            };
          };

          # Make blocky the system resolver: resolved → 127.0.0.1:53 → blocky.
          networking = {
            nameservers = lib.mkForce [ "127.0.0.1" ];
            networkmanager.dns = "systemd-resolved";
          };

          services.resolved = {
            enable = true;
            settings.Resolve = {
              FallbackDNS = "";
              # blocky doesn't forward RRSIGs upstream, so resolved would reject
              # every answer as "no-signature" if DNSSEC validation were on.
              DNSSEC = "false";
              Domains = "~.";
            };
          };
        }
      )
    ];
  };
}
