{
  flake.modules.nixos.github-runner =
    { pkgs, ... }:
    {
      services.github-runners.kgwgk = {
        enable = true;
        url = "https://github.com/kgwgk";
        tokenFile = "/var/lib/github-runners/kgwgk.token";
        name = "zylphia";
        replace = true;
        extraLabels = [ "nixos-zylphia" ];
        extraPackages = with pkgs; [
          git
          nix
        ];
      };

      ephemeralRoot.persist.directories = [
        "/var/lib/github-runners"
      ];
    };
}
