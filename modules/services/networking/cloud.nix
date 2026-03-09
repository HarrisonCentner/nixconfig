{
  flake.modules.homeManager.cloud =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        awscli2
        granted
      ];
      programs.zsh.shellAliases.assume = "source ${pkgs.granted}/bin/assume";
    };
}
