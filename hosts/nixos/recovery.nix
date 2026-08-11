{ inputs, ... }:
{
  flake.modules.nixos."hosts/nixos/recovery" =
    { pkgs, ... }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ];

      environment.systemPackages = with pkgs; [
        testdisk # photorec
        untrunc-anthwlock # repair truncated mp4/mov from a reference file
        exiftool
        jdupes
        rmlint
        ddrescue
        cryptsetup
        btrfs-progs
        sshfs
        rsync
        exfatprogs
        ntfs3g
      ];
    };
}
