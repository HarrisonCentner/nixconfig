{
  flake.modules.nixos.base = {
    services.resolved.llmnr = "false";
  };
}
