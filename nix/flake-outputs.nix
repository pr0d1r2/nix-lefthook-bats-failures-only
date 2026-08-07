{
  self,
  nixpkgs,
  set-and-setting,
  ...
}:
let
  sasLib = set-and-setting.lib;
  supportedSystems = [
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ];
  forAllSystems =
    f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
  fragments = [
    "base"
    "nix"
    "shell"
    "ascii"
    "markdown"
    "yaml"
  ];
in
{
  packages = forAllSystems (pkgs: {
    default = pkgs.writeShellApplication {
      name = "lefthook-bats-failures-only";
      runtimeInputs = [
        (pkgs.bats.withLibraries (p: [
          p.bats-support
          p.bats-assert
          p.bats-file
        ]))
      ];
      text = builtins.readFile ../lefthook-bats-failures-only.sh;
    };
    setting = (sasLib.mkSetting { inherit pkgs; }).materialized;
  });
  devShells = forAllSystems (
    pkgs:
    let
      mat = sasLib.materializationFor { inherit pkgs fragments; };
      sys = pkgs.stdenv.hostPlatform.system;
    in
    sasLib.mkDevShells {
      inherit pkgs;
      basePackages = mat.packages;
      settingHook = ''
        ${self.packages.${sys}.setting}/bin/sync-setting .
        _assemble_out="$(mktemp -d)"
        FRAGMENTS="${builtins.concatStringsSep " " fragments}" out="$_assemble_out" FRAGMENTS_DIR="${set-and-setting}/setting/integrations/lefthook" bash "${set-and-setting}/setting/lib/assemble-lefthook.sh"
        cp -f "$_assemble_out/lefthook.yml" lefthook.yml; rm -rf "$_assemble_out"
      '';
    }
  );
  checks = forAllSystems (
    pkgs:
    (sasLib.checksFor {
      inherit pkgs fragments;
      src = ../.;
    })
    // {
      dep-graph = sasLib.mkDepGraphCheck {
        inherit pkgs;
        projectRoot = ../.;
      };
      default = pkgs.runCommand "checks" { } "touch $out";
    }
  );
  apps = forAllSystems (
    pkgs:
    let
      mat = sasLib.materializationFor { inherit pkgs fragments; };
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
            text = builtins.readFile ../nix/confirm.sh;
          }
        }/bin/confirm";
      };
    }
  );
}
