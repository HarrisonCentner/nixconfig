{
  flake.modules.nixos.shell-host =
    { pkgs, ... }:
    {
      programs.bcc.enable = true;
      environment.systemPackages = [ pkgs.bpftrace ];
    };
}
