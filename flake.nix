{
  description = "A clj-nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    clj-nix.url = "github:jlesquembre/clj-nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    clj-nix,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      javaVersion = 22;
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      checks = {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            cljfmt.enable = true;
            typos.enable = true;
          };
        };
      };

      overlays.default = final: prev: rec {
        jdk = prev."jdk${toString javaVersion}";
        clojure = prev.clojure.override {inherit jdk;};
      };

      packages = {
        default = clj-nix.lib.mkCljApp {
          inherit pkgs;
          modules = [
            # Option list:
            # https://jlesquembre.github.io/clj-nix/options/
            {
              projectSrc = ./.;
              name = "uniref";
              main-ns = "uniref.core";
            }
          ];
        };
      };

      devShells.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        packages = with pkgs; [clojure jdk cljfmt];
      };
    });
}
