{
  flake.modules.nixos.openssh =
    { ... }:
    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };

      networking.firewall.allowedTCPPorts = [ 22 ];

      ephemeralRoot.persist.directories = [
        "/etc/ssh"
      ];
    };
}
