topLevel@{
  inputs,
    ...
}:
let 
  userName = "hcentner";

  homeDirectory = 
        # if inputs.nixpkgs.stdenvNoCC.isDarwin
        #  then "/Users/${userName}"
        "/home/${userName}";
in
{
  flake = {
    meta.users = {
      hcentner = {
        email = "harrisoncent@protonmail.com";
        name = "Harrison Centner";
        username = userName;
        # key = "0AAF2901E8040715"; # ed25519/0x0AAF2901E8040715
        # keygrip = [
        # ];
        # authorizedKeys = [
        # ];
      };
    };

    modules.nixos.${userName} = { pkgs, ...}: {
      users.users.${userName} = {
        description = topLevel.config.flake.meta.users.${userName}.name;
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "networkmanager"
          "tty"
          "wheel"
          "docker"
        ];
        openssh.authorizedKeys.keys = topLevel.config.flake.meta.users.${userName}.authorizedKeys;
        initialPassword = "hkc";
      };

      nix.settings.trusted-users = [ topLevel.config.flake.meta.users.${userName}.username ];
    };

    modules.nixos.base = { pkgs, ...}: {
      users.users.${userName} = { 
        isNormalUser = true; 
        extraGroups = [ 
          "wheel" 
          "networkmanager" 
          "docker"
          "tty"
        ]; 
        shell = pkgs.zsh;
      };
    };
    modules.homeManager.base = {
      home = {
        # homeDirectory = homeDirectory;
        stateVersion = "24.11";
        sessionPath = [
          "${homeDirectory}/nixconfig"
        ];
        sessionVariables = {
          EDITOR = "vim";
        };
        file.".vimrc".source = ../../shell/vimrc.txt;
        file.".vim/coc-settings.json".text = ''
        {
          "suggest.autoTrigger": "always",
            "diagnostic.virtualText": true,
            "languageserver": {
              "dhall": {
                "command": "dhall-lsp-server",
                "filetypes": [
                  "dhall"
                ]
            }
          },
          "languageserver": {
            "clojure-lsp": {
              // "command": "bash",
              // "args": ["-c", "cd /Users/case/dev/lsp && clojure -J-Duser.dir=$PWD -Scp $(clj -Spath) -m clojure-lsp.main"],
              // "args": ["-c", "export LEIN_JVM_OPTS=\"-Duser.dir=$cwd\" && cd /Users/case/dev/lsp/ && lein run"],
              //"command": "bash",
              //"args": ["-c", "cd /Users/case/dev/lsp/cli && clj -M:run"],
              "command": "clojure-lsp",
              //"command": "/Users/snoe/dev/clojure-lsp/clojure-lsp",
              "filetypes": ["clojure"],
              "rootPatterns": ["project.clj", "deps.edn"],
              "additionalSchemes": ["jar", "zipfile"],
              "trace.server": "verbose",
              "progressOnInitialization": true,
              "diagnostic.showUnused": true,
              "diagnostic.showDeprecated": true,
              "diagnostic.highlightPriority": 1000000,
              "initializationOptions": {
                "ignore-classpath-directories": true
              }
            },
          },
          "clojure.initialization-options.semantic-tokens?": true,
          "clojure.initialization-options.use-metadata-for-privacy?": true,
          "clojure.lsp-check-on-start": false,
          "clojure.startup-message": true,
          "clojure.trace.server": "verbose",
          "[clojure]": {
            "semanticTokens.enable": true
          },
          "diagnostic-languageserver.linters": {
            "clj_kondo_lint": {
              "command": "clj-kondo",
              "debounce": 100,
              "args": [ "--lint", "%filepath"],
              "offsetLine": 0,
              "offsetColumn": 0,
              "sourceName": "clj-kondo",
              "formatLines": 1,
              "formatPattern": [
                  "^[^:]+:(\\d+):(\\d+):\\s+([^:]+):\\s+(.*)$",
                  {
                      "line": 1,
                      "column": 2,
                      "message": 4,
                      "security": 3
                  }
              ],
              "securities": {
                      "error": "error",
                      "warning": "warning",
                      "note": "info"
              }

            }
          },
          "diagnostic-languageserver.filetypes": {"clojure":"clj_kondo_lint"}
          }
        '';
      };
      programs.home-manager.enable = true;
    };

  };
}
