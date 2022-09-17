{ lib }:

with lib;

let
  repo = "quay.io/jetstack";
  imagePrefix = "cert-manager-";

  images-src = {
    controller = {
      "v1.9.1" = {
        imageDigest = "sha256:cd9bf3d48b6b8402a2a8b11953f9dc0275ba4beec14da47e31823a0515cde7e2";
        sha256 = {
          amd64 = "sha256-58t7veqtF8dbv4mIEGbJ2cpDtQ+TtPLcsKYQ/wXY80w=";
          arm64 = "sha256-6GvTjgoOm/oHskL1xorJikY7fLObnR4EZ6UsqKHVP0A=";
        };
      };
    };
    webhook = {
      "v1.9.1" = {
        imageDigest = "sha256:4ab2982a220e1c719473d52d8463508422ab26e92664732bfc4d96b538af6b8a";
        sha256 = {
          amd64 = "sha256-YTLNfb6tU0lXQOHQqN5eYxAgbtHcLVBrlbmleT0B5D0=";
          arm64 = "sha256-O5mFBFqF5KpsboOhe21sPDfj63BZmPs1nWdOepVxDRs=";
        };
      };
    };
    cainjector = {
      "v1.9.1" = {
        imageDigest = "sha256:df7f0b5186ddb84eccb383ed4b10ec8b8e2a52e0e599ec51f98086af5f4b4938";
        sha256 = {
          amd64 = "sha256-rTv7wgjQ8XRBU7aqfykYtRxhacxXZ6A61V84oZgmdPk=";
          arm64 = "sha256-NGTbQmKHz/C2u9KOT6I3BY0D7rtTJRd+fHRMzvRpU/s=";
        };
      };
    };
    ctl = {
      "v1.9.1" = {
        imageDigest = "sha256:468c868b2cbae19a5d54d34b6f1c27fe54b0b3988a6d8cab74455f5411d95e96";
        sha256 = {
          amd64 = "sha256-/NF5fGf+FSRNUwvUIfqvXM5HzjSVSnNtMyNdZrpA6uQ=";
          arm64 = "sha256-cBUDMGsE3tvyx/3cevldl0Cjq/bVm63oqQc+JT3oUuo=";
        };
      };
    };
  };

in lib.flatten (lib.attrsets.mapAttrsToList (name: imageset :
  lib.attrsets.mapAttrsToList (version: image: {
    imageName = "${repo}/${imagePrefix}${name}";
    finalImageTag = version;
    imageDigest = image.imageDigest;
    sha256 = image.sha256;
  }) imageset
) images-src)
