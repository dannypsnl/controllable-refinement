{
  description = "controllable-refinement";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils}: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in rec {
      packages = pkgs;
      #defaultPackage = pkgs.build;
      devShell = pkgs.mkShell {
        #buildInputs = [ pkgs.racket ];
      };
    }
  );
}
