{
  flake.modules.nixos.openssh =
    { ... }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      ephemeralRoot.persist.directories = [
        "/etc/ssh"
      ];
    };
}
