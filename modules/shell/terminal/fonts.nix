{
  flake.modules.nixos.shell =
    { pkgs, ... }:
    let
      apple-color-emoji = pkgs.stdenvNoCC.mkDerivation {
        pname = "apple-color-emoji";
        version = "macos-26-20260613";
        src = pkgs.fetchurl {
          url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/macos-26-20260613-f1fc560b/AppleColorEmoji-Linux.ttf";
          hash = "sha256-uMjtl/ZCuJuko2o+CWYZ8IBdBswlrhEW5pU7mBQq4gw=";
        };
        dontUnpack = true;
        installPhase = "install -Dm444 $src $out/share/fonts/truetype/AppleColorEmoji.ttf";
      };
    in
    {
      fonts = {
        fontconfig = {
          enable = true;
          defaultFonts.emoji = [ "Apple Color Emoji" ];
        };
        packages = [
          pkgs.noto-fonts-cjk-sans
          pkgs.noto-fonts-cjk-serif
          apple-color-emoji
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
