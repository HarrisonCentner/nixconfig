{
  # Wrap an alias command that forwards its args to target with
  # completion files delegating to target's completions in each shell.
  _module.args.mkCompletionAlias =
    pkgs: target: package:
    let
      alias = package.meta.mainProgram or (pkgs.lib.getName package);
    in
    pkgs.symlinkJoin {
      name = alias;
      paths = [
        package
        (pkgs.writeTextDir "share/zsh/site-functions/_${alias}" ''
          #compdef ${alias}
          _${target} "$@"
        '')
        (pkgs.writeTextDir "share/bash-completion/completions/${alias}" ''
          . "''${BASH_SOURCE[0]%/*}/${target}"
          complete -o filenames -F _${target} ${alias}
        '')
        (pkgs.writeTextDir "share/fish/vendor_completions.d/${alias}.fish" ''
          complete -c ${alias} --wraps ${target}
        '')
      ];
    };
}
