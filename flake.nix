{
  description = "A clj-nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    clj-nix.url = "github:jlesquembre/clj-nix";
  };

  outputs = { self, nixpkgs, flake-utils, clj-nix }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        {
          packages = {
            default = clj-nix.lib.mkCljApp {
              pkgs = nixpkgs.legacyPackages.${system};
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
            packages = with pkgs; [ clojure ];
          };
        });
}
