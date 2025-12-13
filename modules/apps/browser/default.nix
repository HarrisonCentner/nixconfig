{
  flake.modules.homeManager.browser = { pkgs, ...}: {
    programs.firefox.enable = true;
    home.packages = with pkgs; [
      tor-browser
      tor
      ungoogled-chromium
    ];
  };
}
