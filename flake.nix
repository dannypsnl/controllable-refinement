{
  description = "controllable-refinement";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in rec {
      defaultPackage = pkgs.stdenv.mkDerivation rec {
        pname = "controllable-refinement";
        version = "0";
        src = ./.;
        buildInputs = with pkgs; [ racket-minimal ];
        installPhase = ''
          raco pkg install --auto
        '';
      };
      devShell = pkgs.mkShell {};
    }
  );
}
