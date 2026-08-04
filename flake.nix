{
  description = "CHANGEME";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting.url = "github:pr0d1r2/set-and-setting";
  };

  outputs =
    { self, nixpkgs, set-and-setting, ... }:
    set-and-setting.lib.mkConsumerFlake {
      inherit self nixpkgs set-and-setting;
      lib = set-and-setting.lib;
      src = ./.;
      fragments = [ "base" "nix" "shell" "ascii" "markdown" "yaml" ];
      includeSet = false;
    };
/*
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    {
      packages = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = pkgs.writeShellApplication {
          name = "lefthook-bats-failures-only";
          runtimeInputs = [
            (pkgs.bats.withLibraries (p: [
              p.bats-support
              p.bats-assert
              p.bats-file
            ]))
          ];
          text = builtins.readFile ./lefthook-bats-failures-only.sh;
        };
        setting = (set-and-setting.lib.mkSetting { inherit pkgs; }).materialized;
      });

      devShells = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (system: let pkgs = nixpkgs.legacyPackages.${system}; in
        let
          fragments = [ "base" "nix" "shell" "ascii" "markdown" "yaml" ];
          mat = set-and-setting.lib.materializationFor { inherit pkgs fragments; };
          sys = pkgs.stdenv.hostPlatform.system;
        in
        set-and-setting.lib.mkDevShells {
          inherit pkgs;
          basePackages = mat.packages;
          settingHook = ''
            ${self.packages.${sys}.setting}/bin/sync-setting .
            _assemble_out="$(mktemp -d)"
            FRAGMENTS="${builtins.concatStringsSep " " fragments}" \
              out="$_assemble_out" \
              FRAGMENTS_DIR="${set-and-setting}/setting/integrations/lefthook" \
              bash "${set-and-setting}/setting/lib/assemble-lefthook.sh"
            cp -f "$_assemble_out/lefthook.yml" lefthook.yml
            rm -rf "$_assemble_out"
          '';
        }
      );

      checks = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (system: let pkgs = nixpkgs.legacyPackages.${system}; in
        (set-and-setting.lib.checksFor {
          inherit pkgs;
          fragments = [ "base" "nix" "shell" "ascii" "markdown" "yaml" ];
          src = ./.;
        })
        // {
          dep-graph = set-and-setting.lib.mkDepGraphCheck {
            inherit pkgs;
            projectRoot = ./.;
          };
          default = pkgs.runCommand "checks" { } "touch $out";
        }
      );

      apps = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ] (system: let pkgs = nixpkgs.legacyPackages.${system}; in
        let
          fragments = [ "base" "nix" "shell" "ascii" "markdown" "yaml" ];
          mat = set-and-setting.lib.materializationFor { inherit pkgs fragments; };
        in
        {
          confirm = {
            type = "app";
            program = "${
              pkgs.writeShellApplication {
                name = "confirm";
                runtimeInputs = [
                  pkgs.coreutils
                  pkgs.diffutils
                  pkgs.findutils
                  pkgs.gawk
                  pkgs.git
                  pkgs.gnugrep
                ]
                ++ mat.packages;
                text =
                  builtins.replaceStrings
                    [
                      "@FRAGMENTS_DIR@"
                      "@ASSEMBLE_SCRIPT@"
                      "@DETECT_SCRIPT@"
                      "@SETTING_SRC@"
                      "@CONFIRM_SCRIPT@"
                      "@CONFIRM_REV@"
                    ]
                    [
                      "${set-and-setting}/setting/integrations/lefthook"
                      "${set-and-setting}/setting/lib/assemble-lefthook.sh"
                      "${set-and-setting}/setting/lib/detect-fragments.sh"
                      "${self.packages.${pkgs.stdenv.hostPlatform.system}.setting}"
                      "${set-and-setting}/lib/confirm.sh"
                      "${set-and-setting.rev or "unknown"}"
                    ]
                    (builtins.readFile ./nix/confirm.sh);
              }
            }/bin/confirm";
          };
        }
      );
    };
*/
}
