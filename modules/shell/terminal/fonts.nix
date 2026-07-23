{ appleColorEmoji, ... }:
{
  flake.modules.nixos.shell =
    { pkgs, ... }:
    {
      fonts = {
        fontconfig = {
          enable = true;
          defaultFonts.emoji = [ "Apple Color Emoji" ];
          localConf = ''
            <match target="pattern">
              <test name="family"><string>Noto Color Emoji</string></test>
              <edit name="family" mode="assign" binding="same"><string>Apple Color Emoji</string></edit>
            </match>
          '';
        };
        packages = [
          pkgs.noto-fonts-cjk-sans
          pkgs.noto-fonts-cjk-serif
          (appleColorEmoji pkgs)
        ];
      };
    };

  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nerd-fonts.fira-code
      ];
    };
}
