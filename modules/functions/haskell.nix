{
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
