{
  flake.modules.nixos.library = {
    # prevent USB autosuspend for Kindle to avoid reset/disconnect cycle
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1949", ATTR{power/autosuspend}="-1", MODE="0666"
    '';
  };

  flake.modules.homeManager.library =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        zotero
      ];
    };
}
