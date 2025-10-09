{ pkgs, nixos-mailserver, ... }: 
let domain-name = "hcentner.com";
in
nixos-mailserver.nixosModule {
  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.${domain-name}";
    domains = [ "${domain-name}" ];

    loginAccounts = {
      "user1@${domain-name}" = {
        hashedPasswordFile = "/a/file/containing/a/hashed/password";
        aliases = ["postmaster@${domain-name}"];
      };
      "user2@${domain-name}" = { 
        hashedPasswordFile = "/a/file/containing/a/hashed/password";
        aliases = ["postmaster@${domain-name}"];
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "security@${domain-name}";
}
