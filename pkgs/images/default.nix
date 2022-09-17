{ pkgs, system }:

with pkgs; with lib;

let
  images = (import ./cert-manager-ctl.nix {})
    // (import ./cert-manager-cainjector.nix {})
    // (import ./cert-manager-webhook.nix {})
    // (import ./cert-manager-controller.nix {})
    // (import ./csi-node-driver-registrar.nix {})
    // (import ./busybox.nix {})
  ;

  # Build the resulting derivation name for this image.
  buildImageDerivationName = (imagesetName: tag:
    lib.replaceStrings
      ["."] ["_"]
      "image/${imagesetName}:${tag}"
  );

  pullImage = (name: imagesetName: image: tag: {
    name = name;

    value = dockerTools.pullImage rec {
      imageName = imagesetName;
      finalImageName = imageName;
      finalImageTag = tag;
      imageDigest = image.imageDigest;

      # Always use linux for now.
      os = "linux";

      # Select the correct sha256 based on the current target system.
      sha256 = image.sha256.${arch};

      # Select the correct docker arch based on the current target
      # system. We only support amd64 and arm64 for now.
      arch = if hasPrefix "x86_64" system then "amd64" else "arm64";
    };
  });

  # Pull all images in all image sets.
  pulledImages = attrsets.foldAttrs (n: a: n // a ) {}  ( attrValues(
    mapAttrs (imagesetName: imageset:
    attrsets.mapAttrs' (tag: image:
      pullImage (buildImageDerivationName imagesetName tag) imagesetName image tag
    ) (imageset.imageTags)
    ) images)
  );

  # Create preferred images for all images in all image sets. These become
  # aliases to the tag which is preferred.
  preferredImages = attrsets.foldAttrs (n: a: n // a ) {}  ( attrValues(
    mapAttrs (imagesetName: imageset:
    attrsets.mapAttrs' (tag: image:
      pullImage (buildImageDerivationName imagesetName "preferred") imagesetName image tag
    ) (filterAttrs (tag: _: imageset.preferredTag == tag) imageset.imageTags) # Filter for preferred tag.
    ) images)
  );

in pulledImages // preferredImages
