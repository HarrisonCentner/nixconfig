{
  flake.modules.nixos.base = {
    services.resolved.settings.Resolve.LLMNR = "false";
  };
}
