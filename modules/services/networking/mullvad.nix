{
  flake.modules.nixos.mullvad = {
    services.mullvad-vpn = {
      enable = true;
      # setuid wrapper; required for mullvad-exclude / GUI split tunneling
      enableExcludeWrapper = true;
    };

    # Otherwise NetworkManager adopts the daemon-owned tunnel as an external
    # connection, and any UI offering "disconnect" tears it down while the
    # kill switch keeps blocking — no tunnel, no traffic.
    networking.networkmanager.unmanaged = [ "interface-name:wg*-mullvad" ];
  };
}
