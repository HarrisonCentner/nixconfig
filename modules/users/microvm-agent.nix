{
  config,
  ...
}:
let
  userName = "microvm-agent";
in
{
  flake.modules.nixos.${userName} = {
    users.users.${userName} = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "wheel" ];
      initialPassword = "microvm";
    };
  };
}
