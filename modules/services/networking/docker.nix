{
  flake.modules.nixos.docker =
    { pkgs, ... }:
    {
      virtualisation.docker.enable = true;

      ephemeralRoot.persist.directories = [
        "/var/lib/docker"
      ];
    };

  flake.modules.homeManager.docker =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        docker
      ];
    };
}
