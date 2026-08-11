{ inputs, ... }:
{
  # Host prerequisites for romeai's `devenv-container` CLI (machinectl-managed
  # nspawn devenv per worktree): networkd policy for the ve-devenv-* veths
  # (NetworkManager leaves them unconfigured), machinectl polkit for wheel,
  # and the devenv-container-priv helper + its narrow sudoers rule.
  flake.modules.nixos.devenv-container-host = {
    imports = [ "${inputs.romeai}/nix/hosts-modules/devenv-container-host.nix" ];
  };
}
