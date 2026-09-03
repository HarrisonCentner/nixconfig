{ config, ... }:
let
  nixMineralModule = config.flake.modules.nixos.nix-mineral;
  dockerModule = config.flake.modules.nixos.docker;
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
      # Guard the real host config: nix-mineral merging bind into the
      # dedicated /home subvolume mount fails stage-2 activation, and qemu
      # test VMs override fileSystems entirely so this can't be a VM test.
      checks.nix-mineral-home-mount =
        let
          homeOptions = config.flake.nixosConfigurations.rwzfs.config.fileSystems."/home".options;
        in
        assert !(lib.elem "bind" homeOptions);
        assert !(lib.elem "noexec" homeOptions);
        pkgs.runCommand "nix-mineral-home-mount" { } "touch $out";

      checks.nix-mineral-docker =
        let
          clientImage = pkgs.dockerTools.buildImage {
            name = "test-client";
            tag = "latest";
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = [ pkgs.busybox ];
              pathsToLink = [ "/bin" ];
            };
          };
        in
        pkgs.testers.runNixOSTest {
          name = "nix-mineral-docker";

          nodes = {
            machine = {
              imports = [
                nixMineralModule
                dockerModule
                # Stub ephemeralRoot.persist (real definition lives in base).
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
            };

            server = {
              services.nginx = {
                enable = true;
                virtualHosts.default.locations."/".return = "200 'hello from server'";
              };
              networking.firewall.allowedTCPPorts = [ 80 ];
            };
          };

          testScript = ''
            start_all()
            server.wait_for_unit("nginx.service")
            machine.wait_for_unit("multi-user.target")

            # No unit may fail at boot under the hardened config.
            machine.succeed("systemctl is-system-running --wait")
            server.succeed("systemctl is-system-running --wait")

            # Forwarding must not be clamped in the boot-time sysctl config.
            # dockerd re-enables ip_forward at runtime, which would mask a
            # regression, so check the generated config rather than only the
            # live value.
            machine.fail(
                "grep -E '^net[.]ipv4[.]ip_forward *= *0' /etc/sysctl.d/60-nixos.conf"
            )
            machine.fail(
                "grep -E '^net[.]ipv4[.]conf[.]all[.]forwarding *= *0' /etc/sysctl.d/60-nixos.conf"
            )

            # hidepid on /proc breaks Wayland sessions; the compatibility
            # preset loses this merge upstream, so it is forced off.
            machine.fail("findmnt -no OPTIONS /proc | grep hidepid")

            # Hardening that should be active. qemu-vm.nix replaces all of
            # fileSystems at mkVMOverride priority, so nix-mineral's normal
            # mounts (/var, /home) cannot be asserted here — only
            # boot.specialFileSystems survive in test VMs.
            machine.succeed("[ \"$(sysctl -n kernel.yama.ptrace_scope)\" = 1 ]")
            machine.succeed("findmnt -no OPTIONS /dev/shm | grep noexec")
            machine.fail("modprobe cifs")
            machine.fail("modprobe firewire-core")
            # daily drivers that hardening must never block: bluetooth
            # (desktop), usb-storage/uas (kindle over USB)
            machine.succeed("modprobe bluetooth")
            machine.succeed("modprobe usb-storage")
            machine.succeed("modprobe uas")

            # End to end: container -> docker0 -> NAT via eth1 -> other node.
            # Exercises ip_forward and masquerade under nix-mineral's network
            # hardening (rp_filter, ARP restrictions).
            machine.wait_for_unit("docker.service")
            machine.succeed("docker load < ${clientImage}")
            server_ip = server.succeed(
                "ip -o -4 addr show eth1 | awk '{print $4}' | cut -d/ -f1"
            ).strip()
            machine.succeed("sysctl -n net.ipv4.ip_forward | grep -qx 1")
            response = machine.succeed(
                f"docker run --rm test-client wget -qO- http://{server_ip}/"
            )
            assert "hello from server" in response, f"unexpected response: {response}"
          '';
        };
    };
}
