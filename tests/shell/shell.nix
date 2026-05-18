{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs.haskellPackages; [
          (ghcWithPackages (h: [
            h.turtle
            h.tomland
            h.yaml
            h.base64-bytestring
            h.aeson
          ]))
          fourmolu
        ];
      };
    };
}
