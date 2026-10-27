{
  flake.modules.nixos.security = {
    security.pki.caCertificateBlacklist = [ "emSign Root CA - G1" ];
  };
}
