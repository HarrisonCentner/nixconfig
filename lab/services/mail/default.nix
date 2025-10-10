let domain-name = "hcentner.com";
in
{
  mailserver = {
    enable = true;
    stateVersion = 3;
    localDnsResolver = false;
    fqdn = "mail.${domain-name}";
    domains = [ "${domain-name}" ];

    loginAccounts = {
      "hcentner@${domain-name}" = {
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
