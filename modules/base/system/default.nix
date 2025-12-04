{
  flake.modules =
    let
      stateVersion = 5;
    in
    {
      homeManager.base = {
        home = {
          stateVersion = "24.11";
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
