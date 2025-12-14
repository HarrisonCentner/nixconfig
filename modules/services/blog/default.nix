let
  defaultPort = 21140;
  dir = "hcentner-blog";
  state-dir = "/var/lib/${dir}";
in
{ 
  flake.modules.nixos.services.blog = 
  { pkgs, hcentner-blog, ... }:
  {
    config = {
      environment.etc."hcentner-blog".source = hcentner-blog;
      systemd.services.blog = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        description = "Personal blog.";
        path = [ pkgs.coreutils ]; 
        script = ''
          ${hcentner-blog.packages.${pkgs.system}.default}/bin/site watch --host 0.0.0.0  --port ${defaultPort}
        ''; 
        postStop = ''
          ${hcentner-blog.packages.${pkgs.system}.default}/bin/site clean
          '';
        serviceConfig = {
          Type = "simple";

          Restart = "on-failure"; 
          RestartSec = "3"; 

          CapabilityBoundingSet = [ 
            "CAP_CHOWN" 
            "CAP_DAC_OVERRIDE" 
            "CAP_FOWNER" 
            "CAP_SETFCAP" 
          ];
          # If only Hakyll let me specify where the files are coming from
          # DynamicUser = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          ReadOnlyPaths = [ "${hcentner-blog}" ];
          ReadWritePaths = [ "${dir}" ];
          InaccessiblePaths = [ "/home" ];
          RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
          RestrictNamespaces = true;
          StateDirectory = "${dir}:";
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = "~@clock @obsolete @cpu-emulation @debug @mount @module @raw-io @reboot @swap";
          UMask = "0077"; 
          WorkingDirectory = "${state-dir}";
        };
      };
      networking.firewall.allowedTCPPorts = [ defaultPort ];
    };
  };
}
