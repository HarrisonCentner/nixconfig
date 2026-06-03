{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages =
          (with pkgs.haskellPackages; [
            (ghcWithPackages (h: [
              h.turtle
              h.tomland
              h.yaml
              h.base64-bytestring
              h.aeson
            ]))
            fourmolu
          ])
          ++ [
            # stdenv's non-interactive bash lacks progcomp; tools that
            # shell out to compgen for completion need this to shadow it
            pkgs.bashInteractive
          ];
      };
    };
}
