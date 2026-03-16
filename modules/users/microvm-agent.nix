{
  config,
  ...
}:
let
  userName = "microvm-agent";
in
{
  flake.modules.nixos.${userName} =
    { pkgs, ... }:
    {
      users.users.${userName} = {
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "networkmanager"
          "tty"
          "wheel"
          "docker"
        ];
        shell = pkgs.zsh;
        initialPassword = "microvm";
      };
      nix.settings.trusted-users = [ userName ];
    };
}
