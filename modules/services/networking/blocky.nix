let
  dnsPort = 53; # port for incoming DNS Queries.
in
{
  flake.modules.nixos.blocky =
    { pkgs, ... }:
    {
      config = {
        services.blocky = {
          enable = true;
          settings = {
            ports = {
              dns = dnsPort;
              http = 4000;
              https = 443;
            };
            log = {
              level = "warning";
              privacy = true;
            };
            upstreams.groups.default = [
              "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
            ];
            # For initially solving DoH/DoT Requests when no system Resolver is available.
            bootstrapDns = {
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
        networking.firewall = {
          allowedTCPPorts = [ dnsPort ];
          allowedUDPPorts = [ dnsPort ];
        };
      };
    };
}
