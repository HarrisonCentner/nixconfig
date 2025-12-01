{
  flake.modules =
    let
      stateVersion = "24.11";
    in
    {
      homeManager.base = {
        home = {
          inherit stateVersion;
        };
      };

      nixos.base = {
        system = {
          inherit stateVersion;
        };
      };

      darwin.base = {
        system = {
          inherit stateVersion;
        };
      };
    };
}
