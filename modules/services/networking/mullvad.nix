{
  flake.modules.nixos.mullvad = {
    services.mullvad-vpn = {
      enable = true;
      # setuid wrapper; required for mullvad-exclude / GUI split tunneling
      enableExcludeWrapper = true;
    };
  };
}
