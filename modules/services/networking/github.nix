{
  flake.modules.nixos.github-runner =
    { pkgs, ... }:
    {
      services.github-runners.hledger-romeai = {
        enable = true;
        url = "https://github.com/kgwgk/hledger-romeai";
        tokenFile = "/var/lib/github-runners/hledger-romeai.token";
        name = "zylphia";
        replace = true;
        extraLabels = [ "nixos-zylphia" ];
        extraPackages = with pkgs; [
          git
          nix
        ];
      };
    };
}
