{ electronVimium, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      vimium = electronVimium pkgs;
      packageJson = pkgs.writeText "package.json" (
        builtins.toJSON {
          name = "vimium-electron-test";
          main = "main.cjs";
        }
      );
      page = pkgs.writeText "page.html" ''
        <!doctype html>
        <html>
          <body>
            <a href="#one">one</a>
            <a href="#two">two</a>
            <div role="treeitem" tabindex="-1"><span>three</span></div>
            <div tabindex="0" style="cursor: pointer">four</div>
            <div tabindex="0">not a hint</div>
            <div id="pane" style="height: 100px; overflow-y: auto"><div style="height: 500px"></div></div>
            <div style="height: 5000px"></div>
            <p id="one">one</p>
            <p id="two">two</p>
            <script>
              pane.scrollTop = pane.scrollHeight;
              document
                .querySelector('[role="treeitem"] span')
                .addEventListener("click", () => (document.title = "clicked"));
            </script>
          </body>
        </html>
      '';
      testApp = pkgs.runCommand "vimium-electron-test-app" { } ''
        mkdir $out
        cp ${packageJson} $out/package.json
        cp ${page} $out/page.html
        substitute ${./app/main.cjs} $out/main.cjs --replace-fail @inject@ ${vimium.inject}
      '';
    in
    lib.mkMerge [
      {
        checks.electron-vimium-shim =
          pkgs.runCommand "electron-vimium-shim" { nativeBuildInputs = [ pkgs.nodejs ]; }
            ''
              node ${./shim-test.mjs} ${vimium.extension}/electron_shim.js
              touch $out
            '';
      }
      # Not a check: VM tests run only in CI (.github/workflows/ci-tests.yml).
      (lib.mkIf (system == "x86_64-linux") {
        legacyPackages.ciTests.electron-vimium = pkgs.testers.runNixOSTest {
          name = "electron-vimium";

          nodes.machine = {
            imports = [
              "${pkgs.path}/nixos/tests/common/user-account.nix"
              "${pkgs.path}/nixos/tests/common/x11.nix"
            ];
            test-support.displayManager.auto.user = "alice";
            virtualisation.memorySize = 2048;
          };

          testScript = ''
            import json

            start_all()
            machine.wait_for_x()
            machine.wait_for_file("/home/alice/.Xauthority")
            machine.succeed(
                "su - alice -c 'DISPLAY=:0 RESULT=/tmp/vimium-result.json "
                "${pkgs.electron}/bin/electron --no-sandbox ${testApp} "
                "> /tmp/electron.log 2>&1 &'"
            )
            machine.wait_for_file("/tmp/vimium-result.json")
            print(machine.succeed("cat /tmp/electron.log"))
            result = json.loads(machine.succeed("cat /tmp/vimium-result.json"))
            assert result["hints"] == 5, f"f should hint two links, a treeitem, a pointer row and a bottom-scrolled pane: {result}"
            assert result["treeitemClicked"], f"treeitem hint did not reach the inner click handler: {result}"
            assert result["scrollY"] > 0, f"j did not scroll: {result}"
          '';
        };
      })
    ];
}
