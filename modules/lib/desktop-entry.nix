let
  renameDesktopEntryNamed =
    pkgs: package: entry: name:
    pkgs.lib.hiPrio (
      pkgs.runCommand "${pkgs.lib.getName package}-desktop-entry"
        { nativeBuildInputs = [ pkgs.desktop-file-utils ]; }
        ''
          desktop-file-install --dir=$out/share/applications \
            --set-name=${pkgs.lib.escapeShellArg name} \
            ${package}/share/applications/${entry}.desktop
        ''
    );
in
{
  _module.args = {
    inherit renameDesktopEntryNamed;
    renameDesktopEntry = pkgs: package: renameDesktopEntryNamed pkgs package "*";
  };
}
