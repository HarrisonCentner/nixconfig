{
  flake.modules.nixos.docker =
    { pkgs, ... }:
    {
      virtualisation.docker.enable = true;
    };

  flake.modules.homeManager.docker =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        docker
      ];
    };
}
