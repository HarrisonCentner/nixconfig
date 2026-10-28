{ config, ... }:
let
  tetragonModule = config.flake.modules.nixos.tetragon;

  initModuleFromFile =
    pkgs:
    pkgs.writers.writePython3Bin "init-module-from-file" { } ''
      import ctypes
      import sys

      libc = ctypes.CDLL(None, use_errno=True)
      with open(sys.argv[1], "rb") as f:
          image = f.read()
      buf = ctypes.create_string_buffer(image, len(image))
      if libc.init_module(buf, ctypes.c_ulong(len(image)), b"") != 0:
          sys.exit(f"init_module: errno {ctypes.get_errno()}")
      print(len(image))
    '';
in
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    lib.optionalAttrs (system == "x86_64-linux") {
      checks.tetragon = pkgs.testers.runNixOSTest {
        name = "tetragon";

        nodes.machine =
          { ... }:
          {
            imports = [
              tetragonModule
              {
                options.ephemeralRoot.persist = {
                  directories = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                  };
                  files = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                  };
                };
              }
            ];

            boot.kernelPackages = pkgs.linuxPackages_latest;
            virtualisation.memorySize = 2048;
            services.tetragon.enable = true;
            environment.systemPackages = [
              (initModuleFromFile pkgs)
              pkgs.xz
              pkgs.zstd
              pkgs.jq
            ];
          };

        testScript = ''
          import json

          start_all()
          machine.wait_for_unit("tetragon.service")
          machine.succeed("systemctl is-active tetragon.service")

          # Wait for Tetragon gRPC socket and policies to be fully loaded
          machine.wait_until_succeeds("tetra status")
          machine.wait_until_succeeds("tetra tracingpolicy list | grep -q sensitive-files")

          # Verify our pure-Nix tracing policies are loaded into the daemon
          policies = machine.succeed("tetra tracingpolicy list")
          assert "sensitive-files" in policies, f"sensitive-files policy missing: {policies}"
          assert "kernel-modules" in policies, f"kernel-modules policy missing: {policies}"
          assert "namespace-privilege" in policies, f"namespace-privilege policy missing: {policies}"

          # Test sensitive file access detection
          machine.succeed("cat /etc/shadow || true")
          machine.wait_until_succeeds("grep -q '/etc/shadow' /var/log/tetragon/tetragon.log")

          machine.succeed("modprobe dummy")
          ko = machine.succeed("modinfo -n ifb").strip()
          machine.succeed(f"case {ko} in *.xz) xz -dc {ko};; *.zst) zstd -dc {ko};; *) cat {ko};; esac > /tmp/ifb.ko")
          size = machine.succeed("init-module-from-file /tmp/ifb.ko").strip()
          machine.succeed("lsmod | grep -q '^ifb '")

          def module_event(fn):
              return machine.wait_until_succeeds(
                  "jq -ce 'select(.process_kprobe.function_name == \"" + fn + "\") | .process_kprobe.args'"
                  " /var/log/tetragon/tetragon.log"
              ).splitlines()[0]

          finit = json.loads(module_event("__x64_sys_finit_module"))
          assert "int_arg" in finit[0] and "string_arg" in finit[1], f"finit_module args: {finit}"

          init = json.loads(module_event("__x64_sys_init_module"))
          assert "size_arg" in init[0], f"init_module image pointer not 64-bit: {init}"
          assert init[1] == {"size_arg": size}, f"init_module len {init[1]} != {size}"
        '';
      };
    };
}
