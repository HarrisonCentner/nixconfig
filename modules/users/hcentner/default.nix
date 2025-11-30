topLevel@{
  inputs,
  ...
}:
let userName = "hcentner";
in
{
  flake = {
    meta.users = {
      hcentner = {
        email = "harrisoncent@protonmail.com";
        name = "Harrison Centner";
        username = username;
        # key = "0AAF2901E8040715"; # ed25519/0x0AAF2901E8040715
        # keygrip = [
        # ];
        # authorizedKeys = [
        # ];
      };
    };

    modules.nixos.${userName} = {
      users.users.${userName} = {
        description = topLevel.config.flake.meta.users.${userName}.name;
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "networkmanager"
          "tty"
          "wheel"
        ];
        openssh.authorizedKeys.keys = topLevel.config.flake.meta.users.${userName}.authorizedKeys;
        initialPassword = "hkc";
      };

      nix.settings.trusted-users = [ topLevel.config.flake.meta.users.${userName}.username ];
    };

    modules.homeManager.${userName} = {
      imports = [
        inputs.infra-private.homeModules.${userName}
      ];
    };
  };
}
