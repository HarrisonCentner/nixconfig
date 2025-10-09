{ config, lib, ... }:
let
  cfg = config.homelab.services.blocky;
  homelab = config.homelab;
in
{
  options.homelab.services.blocky = {
    enable = lib.mkEnableOption "DNS proxy and ad-blocker for the local network.";
  };
  config = lib.mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
      ports.dns = 53; # Port for incoming DNS Queries.
      ports.http = 4000; 
      ports.https = 443;
      log.level = "warn";
      log.privacy = true;
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };
      #Enable blocking of certain domains.
      blocking = {
        denylists = {
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
          fakenews = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"];
          gambling = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts"];
          porn = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts"];
          social = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social-only/hosts"];
        };
        #Configure what block categories are used
        clientGroupsBlock = {
          default = [ "ads" "porn" ];
          iphone = [ "ads" "porn" "social" ];
        };
      };
    };
   };
  };
}
