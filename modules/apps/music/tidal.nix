{ inputs, ... }:
{
  flake.modules.homeManager.tidal =
    { pkgs, ... }:
    let
      supercollider = pkgs.supercollider-with-sc3-plugins;
      sclangConf = pkgs.writeText "sclang_conf.yaml" ''
        includePaths:
          - ${inputs.superdirt}
          - ${inputs.vowel}
      '';
      superdirtBoot = pkgs.writeText "superdirt-boot.scd" ''
        (
        s.options.numBuffers = 1024 * 256;
        s.options.memSize = 8192 * 32;
        s.options.numWireBufs = 64;
        s.options.maxNodes = 1024 * 32;
        s.waitForBoot {
          ~dirt = SuperDirt(2, s);
          ~dirt.loadSoundFiles("${inputs.dirt-samples}/*");
          s.sync;
          ~dirt.start(57120, [0, 0]);
        };
        s.latency = 0.3;
        )
      '';
      superdirt = pkgs.writeShellScriptBin "superdirt" ''
        exec ${supercollider}/bin/sclang -l ${sclangConf} ${superdirtBoot}
      '';
      ghcWithTidal = pkgs.haskellPackages.ghcWithPackages (p: [ p.tidal ]);
      bootTidal = pkgs.runCommand "BootTidal.hs" { } ''
        find ${pkgs.haskellPackages.tidal.data}/share -name BootTidal.hs -exec cp {} $out ';'
        test -s $out
      '';
      tidal = pkgs.writeShellScriptBin "tidal" ''
        exec ${ghcWithTidal}/bin/ghci -ghci-script ${bootTidal}
      '';
    in
    {
      home.packages = [
        pkgs.godot-mono
        pkgs.dotnet-sdk_8
        supercollider
        superdirt
        tidal
      ];
    };
}
