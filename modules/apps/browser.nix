{
  flake.modules.homeManager.browser =
    { pkgs, ... }:
    {
      programs.firefox.enable = true;
      home.packages = with pkgs; [
        ungoogled-chromium
      ];
    };
  # Install extensions on ungoogled-chromium
  #
  #  1. Download the latest release from chromium-web-store [here](https://github.com/NeverDecaf/chromium-web-store).
  #  2. Install the extension as a `.crx` (you might need to download the `.tar` extension and unpack it).
  #  3. Go to the chromium web store and add the required extension.
  #
  #  See extended instructions [here](https://avoidthehack.com/manually-install-extensions-ungoogled-chromium).
}
