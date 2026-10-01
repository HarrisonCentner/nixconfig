{
  flake.modules.nixos.tetragon =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.tetragon;
      format = pkgs.formats.yaml { };

      defaultSettings = {
        server-address = "unix:///run/tetragon/tetragon.sock";
        export-filename = "/var/log/tetragon/tetragon.log";
        export-file-max-size-mb = 20;
        export-file-max-backups = 5;
        export-file-compress = true;
        export-file-rotation-interval = "24h";
        log-level = "info";
        log-format = "json";
        enable-k8s-api = false;
        enable-tracing-policy-crd = false;
        bpf-lib = "${cfg.package}/lib/tetragon/bpf/";
        tracing-policy-dir = "/etc/tetragon/tetragon.tp.d";
        username-metadata = "unix";
        enable-process-ns = true;
        enable-process-cred = true;
      };

      allSettings = lib.recursiveUpdate defaultSettings cfg.settings;
      configFile = format.generate "tetragon.yaml" allSettings;

      defaultPolicies = {
        sensitive-files = {
          apiVersion = "cilium.io/v1alpha1";
          kind = "TracingPolicy";
          metadata = {
            name = "sensitive-files";
          };
          spec = {
            kprobes = [
              {
                call = "sys_openat";
                syscall = true;
                args = [
                  {
                    index = 0;
                    type = "int";
                  }
                  {
                    index = 1;
                    type = "string";
                  }
                  {
                    index = 2;
                    type = "int";
                  }
                ];
                selectors = [
                  {
                    matchArgs = [
                      {
                        index = 1;
                        operator = "Prefix";
                        values = [
                          "/etc/shadow"
                          "/etc/sudoers"
                          "/etc/sudoers.d"
                          "/var/lib/opnix/token"
                        ];
                      }
                    ];
                    matchActions = [
                      {
                        action = "Post";
                        rateLimit = "1m";
                        rateLimitScope = "process";
                      }
                    ];
                  }
                ];
                tags = [
                  "sensitive-files"
                  "audit"
                ];
              }
            ];
          };
        };

        kernel-modules = {
          apiVersion = "cilium.io/v1alpha1";
          kind = "TracingPolicy";
          metadata = {
            name = "kernel-modules";
          };
          spec = {
            kprobes = [
              {
                call = "sys_finit_module";
                syscall = true;
                args = [
                  {
                    index = 0;
                    type = "int";
                  }
                  {
                    index = 1;
                    type = "string";
                  }
                  {
                    index = 2;
                    type = "int";
                  }
                ];
                tags = [
                  "kernel"
                  "module"
                ];
              }
              {
                call = "sys_init_module";
                syscall = true;
                args = [
                  {
                    index = 0;
                    type = "int";
                  }
                  {
                    index = 1;
                    type = "int";
                  }
                  {
                    index = 2;
                    type = "string";
                  }
                ];
                tags = [
                  "kernel"
                  "module"
                ];
              }
            ];
          };
        };

        namespace-privilege = {
          apiVersion = "cilium.io/v1alpha1";
          kind = "TracingPolicy";
          metadata = {
            name = "namespace-privilege";
          };
          spec = {
            kprobes = [
              {
                call = "sys_setns";
                syscall = true;
                args = [
                  {
                    index = 0;
                    type = "int";
                  }
                  {
                    index = 1;
                    type = "int";
                  }
                ];
                tags = [
                  "namespace"
                  "privilege"
                ];
              }
              {
                call = "sys_unshare";
                syscall = true;
                args = [
                  {
                    index = 0;
                    type = "int";
                  }
                ];
                tags = [
                  "namespace"
                  "privilege"
                ];
              }
            ];
          };
        };
      };

      allPolicies = lib.recursiveUpdate defaultPolicies cfg.tracingPolicies;

      policyFiles = lib.mapAttrs' (
        name: policy:
        lib.nameValuePair "tetragon/tetragon.tp.d/${name}.yaml" {
          source = format.generate "${name}.yaml" policy;
        }
      ) allPolicies;

      tetraWrapper = pkgs.writeShellScriptBin "tetra" ''
        args=()
        has_server=false
        for arg in "$@"; do
          if [[ "$arg" == "--server-address" || "$arg" == --server-address=* ]]; then
            has_server=true
          fi
          args+=("$arg")
        done
        if [ "$has_server" = false ]; then
          exec ${cfg.package}/bin/tetra --server-address "${allSettings.server-address}" "''${args[@]}"
        else
          exec ${cfg.package}/bin/tetra "''${args[@]}"
        fi
      '';
    in
    {
      options = {
        services.tetragon = {
          enable = lib.mkEnableOption "Tetragon, eBPF-based security observability and runtime enforcement";

          package = lib.mkPackageOption pkgs "tetragon" { };

          settings = lib.mkOption {
            type = lib.types.submodule {
              freeformType = format.type;
              options = {
                server-address = lib.mkOption {
                  type = lib.types.str;
                  default = defaultSettings.server-address;
                  description = "gRPC server address used by the `tetra` CLI.";
                };
                export-filename = lib.mkOption {
                  type = lib.types.str;
                  default = defaultSettings.export-filename;
                  description = "File to export JSON events to. Empty disables file export.";
                };
                log-level = lib.mkOption {
                  type = lib.types.enum [
                    "trace"
                    "debug"
                    "info"
                    "warn"
                    "error"
                  ];
                  default = defaultSettings.log-level;
                  description = "Daemon log level.";
                };
              };
            };
            default = { };
            description = ''
              Tetragon daemon configuration, written to {file}`/etc/tetragon/tetragon.yaml`.
              Keys are daemon command-line flag names without leading dashes.
            '';
          };

          tracingPolicies = lib.mkOption {
            type = lib.types.attrsOf format.type;
            default = { };
            description = ''
              Tracing policies loaded at startup, each written to
              {file}`/etc/tetragon/tetragon.tp.d/<name>.yaml`.
            '';
          };
        };
      };

      config = lib.mkMerge [
        {
          services.tetragon.enable = lib.mkDefault true;
        }
        (lib.mkIf cfg.enable {
          environment = {
            systemPackages = [
              cfg.package
              (lib.hiPrio tetraWrapper)
            ];
            etc = lib.mkMerge [
              { "tetragon/tetragon.yaml".source = configFile; }
              policyFiles
            ];
          };

          ephemeralRoot.persist.directories = [
            "/var/log/tetragon"
          ];

          systemd.services.tetragon = {
            description = "Tetragon eBPF Security Observability & Enforcement";
            documentation = [ "https://tetragon.io/" ];
            after = [
              "network.target"
              "local-fs.target"
            ];
            wantedBy = [ "multi-user.target" ];
            restartTriggers = [ configFile ] ++ lib.mapAttrsToList (_: f: f.source) policyFiles;
            path = [ pkgs.bpftools ];
            unitConfig = {
              DefaultDependencies = false;
              StartLimitBurst = 10;
              StartLimitIntervalSec = "2min";
              ConditionPathExists = "/sys/kernel/btf/vmlinux";
            };
            serviceConfig = {
              ExecStart = lib.getExe cfg.package;
              Restart = "on-failure";
              RestartSec = 5;
              KillMode = "process";
              LimitMEMLOCK = "infinity";
              LimitNOFILE = 1048576;
              LogsDirectory = "tetragon";
              LogsDirectoryMode = "0700";
              RuntimeDirectory = "tetragon";
              RuntimeDirectoryMode = "0755";
              StateDirectory = "tetragon";
              StateDirectoryMode = "0700";
            };
          };
        })
      ];
    };
}
