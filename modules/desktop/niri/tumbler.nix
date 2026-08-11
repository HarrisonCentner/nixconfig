{
  flake.modules.homeManager.desktop-niri =
    { lib, ... }:
    let
      untrusted = [
        "~/Downloads/untrusted"
        "~/cloud-media"
      ];

      plugins = {
        JPEGThumbnailer.Priority = 3;
        RawThumbnailer.Priority = 3;
        PixbufThumbnailer.Priority = 2;
        CoverThumbnailer = {
          Priority = 3;
          Disabled = true;
        };
        FfmpegThumbnailer.Priority = 2;
        GstThumbnailer.Priority = 1;
        FontThumbnailer.Priority = 1;
        PopplerThumbnailer.Priority = 1;
        OdfThumbnailer.Priority = 1;
        EpubThumbnailer.Priority = 1;
        DesktopThumbnailer.Priority = 0;
      };

      section = name: attrs: ''
        [${name}]
        Disabled=${lib.boolToString (attrs.Disabled or false)}
        Priority=${toString attrs.Priority}
        Excludes=${lib.concatStringsSep ";" untrusted}
        MaxFileSize=0
      '';
    in
    {
      xdg.configFile."tumbler/tumbler.rc".text = lib.concatStringsSep "\n" (
        lib.mapAttrsToList section plugins
      );
    };
}
