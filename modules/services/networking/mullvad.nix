{
  flake.modules.nixos.mullvad = {
    services.mullvad-vpn = {
      enable = true;
      enableExcludeWrapper = false;
    };
  };
}
