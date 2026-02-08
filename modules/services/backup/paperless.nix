{
  flake.modules.nixos.paperless = { ... }:
  {
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
    };
  };
}
