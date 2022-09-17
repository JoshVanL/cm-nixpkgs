{ }:

# File was generated with:
# $ nix develop -c ./hack/fetch-image-digests.sh --image-name=k8s.gcr.io/sig-storage/csi-node-driver-registrar --preferred-tag=v2.5.0 --image-tags=v2.3.0,v2.4.0,v2.5.0

{
  "k8s.gcr.io/sig-storage/csi-node-driver-registrar" = {

    preferredTag = "v2.5.0";

    imageTags = {
      "v2.3.0" = {
        sha256 = {
        amd64 = "0fbf25pxz23i7w3aq34m0vqk9w3j164si6d6mfgax855g41d88z9";
        arm64 = "1vdhjdzvq22835azyx0jyiqlfccwi3pr70apvj09dl0cnrb8ar5g";
        };
        imageDigest = "sha256:f9bcee63734b7b01555ee8fc8fb01ac2922478b2c8934bf8d468dd2916edc405";
      };
      "v2.4.0" = {
        sha256 = {
        amd64 = "0a409a50fxqgbja2c86g72gi030730la3xi2rmqjvmf2da0g3hrd";
        arm64 = "1xixp3dz7xw295c2sxiy964kzrb9kja85mfs36x3plqbbrrrf0nv";
        };
        imageDigest = "sha256:fc39de92284cc45240417f48549ee1c98da7baef7d0290bc29b232756dfce7c0";
      };
      "v2.5.0" = {
        sha256 = {
        amd64 = "1zb161ak2chhblv1yq86j34l2r2i2fsnk4zsvrwzxrsbpw42wg05";
        arm64 = "0hdjhm69fr9dz4msn3bll250mhwkxzm31k5b7wf3yynibrbanw1c";
        };
        imageDigest = "sha256:4fd21f36075b44d1a423dfb262ad79202ce54e95f5cbc4622a6c1c38ab287ad6";
      };
    };
  };
}
