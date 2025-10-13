{ username, homeDirectory,  ... }: 
{
  users.users."${username}".home = "${homeDirectory}";
  nix.settings.trusted-users = [ "${username}" ];
  nix.settings.download-buffer-size = 524288000;
}
