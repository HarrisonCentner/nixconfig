{
  flake.modules.nixos.password-manager =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      programs = {
        _1password-gui.enable = true;
        _1password.enable = true;
      };

      ephemeralRoot.persist.directories = [
        "/etc/1password"
      ];
    };

  flake.modules.homeManager.password-manager =
    { pkgs, ... }:
    {
      ephemeralRoot.persist.directories = [
        ".config/1Password"
        # KeePassXC database and config
        ".keepassxc"
        ".config/keepassxc"
        ".local/share/KeePassXC"
      ];
    };
}
