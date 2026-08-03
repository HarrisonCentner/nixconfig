{
  _module.args.writeHaskellBinWrapped =
    pkgs: name:
    {
      env ? { },
      path ? [ ],
      ...
    }@opts:
    source:
    let
      inherit (pkgs) lib;
      unwrapped = pkgs.writers.writeHaskellBin name (builtins.removeAttrs opts [
        "env"
        "path"
      ]) source;
      flags =
        lib.mapAttrsToList (n: v: "--set ${n} ${lib.escapeShellArg v}") env
        ++ lib.optional (path != [ ]) "--prefix PATH : ${lib.makeBinPath path}";
    in
    pkgs.runCommand name
      {
        nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
        meta.mainProgram = name;
      }
      ''
        makeWrapper ${unwrapped}/bin/${name} $out/bin/${name} ${lib.concatStringsSep " " flags}
      '';

  _module.args.writeHaskellBinCompleted =
    pkgs: name: opts: source:
    let
      bin = pkgs.writers.writeHaskellBin name opts source;
      completions = {
        bash = "bash-completion/completions/${name}";
        zsh = "zsh/site-functions/_${name}";
        fish = "fish/vendor_completions.d/${name}.fish";
      };
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [ bin ];
      postBuild = pkgs.lib.concatStrings (
        pkgs.lib.mapAttrsToList (shell: path: ''
          mkdir -p $out/share/${dirOf path}
          ${bin}/bin/${name} --${shell}-completion-script ${name} > $out/share/${path}
        '') completions
      );
    };
}
