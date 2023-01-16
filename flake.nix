{
  description = "A basic flake for the mbbs package";
  nixConfig = {
    bash-prompt = "funstats> ";
  };
  inputs = {
    # quarto is only on unstable currently
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default =  pkgs.mkShell {
        nativeBuildInputs = [ 
          pkgs.bashInteractive
        ];
        buildInputs = [
          # required by R packages
          pkgs.openssl
          pkgs.gettext
          pkgs.udunits
          pkgs.zlib
          pkgs.hugo
          
          # required by Hmatrix
          pkgs.lapack
          pkgs.blas

          pkgs.R
          pkgs.rPackages.languageserver
          pkgs.rPackages.renv

          pkgs.haskellPackages.haskell-language-server
          pkgs.haskellPackages.cabal-install

          # adga
          (pkgs.agda.withPackages [ pkgs.agdaPackages.standard-library ])
        ];
      }; 

    });
}

