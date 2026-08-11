{ config, ... }:
{
  # closure is embedded in the ISO, so installing needs no network
  flake.modules.nixos."hosts/nixos/zylphia-installer" =
    { pkgs, ... }:
    let
      zylphia = config.flake.nixosConfigurations.zylphia.config.system.build;
    in
    {
      imports = [ config.flake.nixosModules.installer-common ];

      environment.systemPackages = [
        (pkgs.writeShellScriptBin "install-zylphia" ''
          set -euo pipefail
          ${zylphia.diskoScript}
          nixos-install --no-channel-copy --system ${zylphia.toplevel}
        '')
      ];
    };
}
