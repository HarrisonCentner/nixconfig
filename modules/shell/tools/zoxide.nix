{
  flake.modules.homeManager.shell = {
    programs = {
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };

    ephemeralRoot.persist.directories = [
      ".local/share/zoxide"
    ];
  };
}
