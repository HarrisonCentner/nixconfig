let
  electronVimium =
    pkgs:
    let
      extension = pkgs.stdenvNoCC.mkDerivation {
        pname = "vimium-electron";
        version = "2.4.2";
        src = pkgs.fetchFromGitHub {
          owner = "philc";
          repo = "vimium";
          tag = "v2.4.2";
          hash = "sha256-i4JT2moQSVGzygC4BDAqkjioCAJiFCo5Bc5pmIAfovE=";
        };
        nativeBuildInputs = [ pkgs.jq ];
        dontBuild = true;
        installPhase = ''
          cp -r . $out
          chmod -R u+w $out
          cp ${./shim.js} $out/electron_shim.js
          sed -E 's#^(([^"]*"[^"]*")*[^"/]*)//.*#\1#' manifest.json | jq '.content_scripts[0].js |= ["electron_shim.js"] + .' > $out/manifest.json
          for module in background_scripts/main.js pages/{hud_page,vomnibar_page,help_dialog_page,command_listing,doc_search_completion}.js; do
            sed -i '1i import "../electron_shim.js";' $out/$module
          done
          # Electron apps navigate via ARIA treeitems and pointer-cursor tabindex rows.
          # Treeitem handlers sit on a descendant, so click the label instead.
          # Row hints are centred so they don't stack on the hints of the row's own controls.
          substituteInPlace $out/content_scripts/link_hints.js \
            --replace-fail '"menuitemradio",' '"menuitemradio", "treeitem", "option",' \
            --replace-fail 'onlyHasTabIndex = true;' 'onlyHasTabIndex = getComputedStyle(element).cursor !== "pointer";
              if (!onlyHasTabIndex) pointerRows.add(element);' \
            --replace-fail 'el.style.left = localHint.rect.left + "px";' 'el.style.left = localHint.rect.left + (pointerRows.has(localHint.element) ? localHint.rect.width / 2 : 0) + "px";' \
            --replace-fail 'el.style.top = localHint.rect.top + "px";' 'el.style.top = localHint.rect.top + (pointerRows.has(localHint.element) ? localHint.rect.height / 2 - 8 : 0) + "px";' \
            --replace-fail 'clickEl = localHint.element;' 'clickEl = localHint.element;
              if (["treeitem", "option"].includes(clickEl.getAttribute("role"))) {
                const label = document
                  .createTreeWalker(clickEl, NodeFilter.SHOW_TEXT, {
                    acceptNode: (node) => node.textContent.trim() ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_SKIP,
                  })
                  .nextNode();
                if (label) clickEl = label.parentElement;
              }'
          sed -i '1i const pointerRows = new WeakSet();' $out/content_scripts/link_hints.js
          # Upstream only probes downward, so a pane scrolled to the bottom gets no hint.
          substituteInPlace $out/content_scripts/scroller.js \
            --replace-fail 'return (element !== activatedElement) && isScrollableElement(element);' 'return (element !== activatedElement) && (isScrollableElement(element) || isScrollableElement(element, "y", -1));'
        '';
      };
    in
    {
      inherit extension;
      inject = pkgs.replaceVars ./inject.cjs { inherit extension; };
    };
in
{
  _module.args = {
    inherit electronVimium;

    # Repacks the cached output so source-built apps aren't rebuilt locally.
    # Name must equal package.name: the store-path rewrite is in place.
    repackElectronApp =
      pkgs:
      {
        package,
        asar,
        packFlags ? [ ],
        extraPatch ? "",
      }:
      let
        inherit (electronVimium pkgs) inject;
      in
      pkgs.runCommand package.name
        {
          nativeBuildInputs = [
            pkgs.asar
            pkgs.jq
          ];
          inherit (package) meta;
          passthru = package.passthru or { };
        }
        ''
          cp -r ${package} $out
          chmod -R u+w $out
          asar extract $out/${asar} $TMPDIR/app
          (
            cd $TMPDIR/app
            ${extraPatch}
          )
          main=$(jq -r .main $TMPDIR/app/package.json)
          main=''${main#./}
          if [ -d "$TMPDIR/app/$main" ]; then main=$main/index.js; fi
          printf '\nrequire("%s");\n' ${inject} >> "$TMPDIR/app/$main"
          rm -rf $out/${asar} $out/${asar}.unpacked
          asar pack $TMPDIR/app $out/${asar} ${pkgs.lib.escapeShellArgs packFlags}
          grep -rlI ${package} $out | xargs -r sed -i "s|${package}|$out|g"

          cd $TMPDIR
          asar extract-file $out/${asar} "$main"
          grep -qF ${inject} "$(basename "$main")"
        '';
  };
}
