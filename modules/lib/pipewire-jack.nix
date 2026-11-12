{
  # Per-package equivalent of pw-jack: the binaries load PipeWire's libjack.
  _module.args.withPipewireJack =
    pkgs: package:
    pkgs.symlinkJoin {
      inherit (package) name meta;
      paths = [ package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for bin in $out/bin/*; do
          wrapProgram "$bin" --prefix LD_LIBRARY_PATH : ${pkgs.pipewire.jack}/lib
        done
      '';
    };
}
