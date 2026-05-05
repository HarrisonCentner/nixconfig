{
  perSystem =
    { pkgs, ... }:
    {
      _module.args.writeTurtleBin =
        name:
        {
          src,
          extraLibraries ? [ ],
        }:
        pkgs.writers.writeHaskellBin name {
          libraries =
            (with pkgs.haskellPackages; [
              turtle
            ])
            ++ extraLibraries;
        } (builtins.readFile src);
    };
}
