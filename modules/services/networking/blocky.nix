let
  dnsPort = 53; # port for incoming DNS Queries.
  stephenBlackUrl = "https://raw.githubusercontent.com/StevenBlack/hosts/master";
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
            #Enable blocking of certain domains.
            blocking = {
              denylists = {
                ads = [ "${stephenBlackUrl}/hosts" ];
                fakenews = [ "${stephenBlackUrl}/alternates/fakenews-only/hosts" ];
                gambling = [ "${stephenBlackUrl}/alternates/gambling-only/hosts" ];
                porn = [ "${stephenBlackUrl}/alternates/porn-only/hosts" ];
                social = [ "${stephenBlackUrl}/alternates/social-only/hosts" ];
              };
              #Configure what block categories are used
              clientGroupsBlock = {
                default = [
                  "ads"
                  "porn"
                ];
                iphone = [
                  "ads"
                  "porn"
                  "social"
                ];
              };
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
        networking.firewall.allowedTCPPorts = [ dnsPort ];
      };
    };
}
