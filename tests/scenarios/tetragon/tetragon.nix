{ config, ... }:
let
  tetragonModule = config.flake.modules.nixos.tetragon;
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

            virtualisation.memorySize = 2048;
            services.tetragon.enable = true;
          };

        testScript = ''
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
        '';
      };
    };
}
