{
  flake.modules.nixos.ebooks = {
    # prevent USB autosuspend for Kindle to avoid reset/disconnect cycle
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1949", ATTR{power/autosuspend}="-1", MODE="0666"
    '';
  };
}
