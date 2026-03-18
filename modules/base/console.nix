{
  flake.modules = {
    homeManager.base = {
      programs.zsh.enable = true;
    };

    nixos.base =
      { pkgs, ... }:
      {
        users.defaultUserShell = pkgs.zsh;
        programs.zsh.enable = true;

        console = {
          earlySetup = true;
          font = "ter-124b";
          useXkbConfig = true;
          packages = with pkgs; [
            terminus_font
            xterm
          ];
        };
      };
  };
}
