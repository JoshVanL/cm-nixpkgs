{
  description = ''
    A nix flake continuing the canonical resources for cert-manager and dependant projects
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  let
    targetSystems = with flake-utils.lib.system; [
      x86_64-linux
      x86_64-darwin
      aarch64-linux
      aarch64-darwin
    ];

  in flake-utils.lib.eachSystem targetSystems (system:
    let

      pkgs = import nixpkgs { inherit system; };
      images = import ./pkgs/images { inherit pkgs system; };

    in with pkgs.lib; rec {
      packages = images;

      checks =  attrsets.foldAttrs (n: a: n // a ) {}  (
        forEach targetSystems (checkSystem:
          mapAttrs' (name: image:
            nameValuePair "${checkSystem}/${name}" image
          ) (import ./pkgs/images { inherit pkgs; system = checkSystem; })
        )
      );

      # mkShell is able to setup the nix shell environment (`$ nix develop`).
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.bash
            pkgs.getopt
            pkgs.nix-prefetch-docker
            pkgs.jq
          ];
        };
  });
}
