{
  _module.args.writeHaskellBinWrapped =
    pkgs: name:
    {
      env ? { },
      path ? [ ],
      libraries ? [ ],
      ...
    }@opts:
    source:
    let
      inherit (pkgs) lib;

      unwrapped = pkgs.writers.writeHaskellBin name (
        builtins.removeAttrs opts [
          "env"
          "path"
          "libraries"
        ]
        // {
          libraries = lib.unique ([ pkgs.haskellPackages.optparse-applicative ] ++ libraries);
        }
      ) source;

      flags =
        lib.mapAttrsToList (n: v: "--set ${n} ${lib.escapeShellArg v}") env
        ++ lib.optional (path != [ ]) "--prefix PATH : ${lib.makeBinPath path}";

      wrapped =
        if flags == [ ] then
          unwrapped
        else
          pkgs.runCommand name
            {
              nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
              meta.mainProgram = name;
            }
            ''
              makeWrapper ${unwrapped}/bin/${name} $out/bin/${name} ${lib.concatStringsSep " " flags}
            '';

      completionFiles = {
        bash = "bash-completion/completions/${name}";
        zsh = "zsh/site-functions/_${name}";
        fish = "fish/vendor_completions.d/${name}.fish";
      };
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [ wrapped ];
      meta.mainProgram = name;
      # every wrapped binary parses with optparse-applicative, which answers
      # --*-completion-script before main runs
      postBuild = lib.concatStrings (
        lib.mapAttrsToList (shell: file: ''
          mkdir -p $out/share/${dirOf file}
          ${wrapped}/bin/${name} --${shell}-completion-script ${name} > $out/share/${file}
        '') completionFiles
      );
    };
}
