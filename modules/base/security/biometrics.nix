{
  flake.modules.nixos.biometrics =
    { pkgs, ... }:
    {
      services.fprintd.enable = true;

      security.pam.services = {
        login.fprintAuth = true;
        sudo.fprintAuth = true;
      };

      environment.systemPackages = with pkgs; [
        fprintd
      ];

      ephemeralRoot.persist.directories = [
        "/var/lib/fprint"
      ];
    };
}
