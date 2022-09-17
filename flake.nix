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
      charts = import ./pkgs/charts { inherit pkgs; };

    in with pkgs.lib; rec {
      packages = images // charts;

      # Since we're using the `eachSystem` function, `$ flake check` would
      # normally only check the docker pulls for the images which match the
      # current systems architecture. We get around this by adding every
      # architectures image into each system, so check will verify all of them.
      checks = packages // attrsets.foldAttrs (n: a: n // a ) {}  (
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
