{
  config,
  ...
}:
{
  flake = {
    meta.users = {
      user = {
        name = "Utilisateur";
        key = "";
        username = "user";
        keygrip = [
        ];
        authorizedKeys = [
        ];
      };
    };

    modules.nixos.user = {
      users.users.user = {
        description = config.flake.meta.users.user.name;
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "networkmanager"
          "tty"
          "docker"
        ];
        initialPassword = "hkc";
      };

      nix.settings.trusted-users = [ config.flake.meta.users.user.username ];
    };
  };
}
