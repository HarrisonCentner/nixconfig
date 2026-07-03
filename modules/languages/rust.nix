{
  flake.modules.homeManager.rust =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.sccache ];

      programs.cargo = {
        enable = true;
        # toolchains come from per-project devshells
        package = null;
        settings = {
          build = {
            # negative = all cores minus one
            jobs = -1;
            rustc-wrapper = lib.getExe' pkgs.sccache "sccache";
            target-dir = "${config.home.homeDirectory}/.cache/cargo-target";
          };
          profile.dev.package."*" = {
            debug = false;
            incremental = false;
          };
        };
      };

      # --bind-try skips missing sources, so shared cache dirs must pre-exist
      home.activation.cargoSharedCaches = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p ${config.home.homeDirectory}/.cache/cargo-target ${config.home.homeDirectory}/.cache/sccache
      '';
    };
}
