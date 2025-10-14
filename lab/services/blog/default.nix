{ config, system, lib, hcentner-blog, ... }:
let
  cfg = config.homelab.services.blog;
in
{
  options.homelab.services.blog = {
    enable = lib.mkEnableOption "hcentner.com blog.";
  };
  config = lib.mkIf cfg.enable {
       systemd.services.blog = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Personal blog.";
      serviceConfig = {
        Type = "simple";
        Envionment = [ ]; 
        ExecStart = ''${hcentner-blog.packages.${system}.default}/bin/site server''; 
        
        Restart = "always"; 
        ReadWritePaths = ["/var/lib/hcentner-blog"]; 
        ProtectSystem = "strict";
        ProtectHome = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        SystemCallFilter = "~@clock @cpu-emulation @debug @module @mount @raw-io @reboot @swap";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
      };
    };
 
   };
}
