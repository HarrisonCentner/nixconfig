{ inputs, ... }:
{
  flake.modules.nixos.secrets =
    { lib, ... }:
    let
      dummy = lib.mkDefault ./dummy.age;
      mkSecret = owner: {
        file = dummy;
        inherit owner;
      };
    in
    {
      imports = [ inputs.agenix.nixosModules.default ];

      age.identityPaths = lib.mkDefault [ "${./dummy-key.txt}" ];

      age.secrets = {
        "sonarr/api_key" = mkSecret "sonarr";
        "sonarr/password" = mkSecret "sonarr";
        "sonarr-anime/api_key" = mkSecret "sonarr-anime";
        "sonarr-anime/password" = mkSecret "sonarr-anime";
        "radarr/api_key" = mkSecret "radarr";
        "radarr/password" = mkSecret "radarr";
        "lidarr/api_key" = mkSecret "lidarr";
        "lidarr/password" = mkSecret "lidarr";
        "prowlarr/api_key" = mkSecret "prowlarr";
        "prowlarr/password" = mkSecret "prowlarr";
        "jellyfin/api_key" = mkSecret "jellyfin";
        "jellyfin/admin_password" = mkSecret "jellyfin";
        "seerr/api_key" = mkSecret "seerr";
        "sabnzbd/api_key" = mkSecret "sabnzbd";
        "sabnzbd/nzb_key" = mkSecret "sabnzbd";
        "qbittorrent/password" = mkSecret "qbittorrent";
        "wireguard/conf" = mkSecret "wireguard";
        "kopia/env" = mkSecret "kopia";
      };
    };
}
