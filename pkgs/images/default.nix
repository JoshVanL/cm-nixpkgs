{ pkgs, system }:

with pkgs;

let
  images = []
  ++ import ./cert-manager.nix {inherit lib; }
  ;

in lib.attrsets.listToAttrs (map (image: {
  name = (lib.replaceStrings
    ["."] ["_"]
    "image/${image.imageName}:${image.finalImageTag}"
  );

  value = dockerTools.pullImage rec {
    inherit (image) imageName finalImageTag imageDigest;
    finalImageName = imageName;
    os = "linux";

    # Select the correct docker arch based on the current target
    # system. We only support amd64 and arm64 for now.
    arch = if lib.hasPrefix "x86_64" system then "amd64" else "arm64";

    # Select the correct sha256 based on the current target system.
    sha256 = image.sha256.${arch};
  };
}) (images))
