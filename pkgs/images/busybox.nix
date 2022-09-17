{ }:

# File was generated with:
# $ nix develop -c ./hack/fetch-image-digests.sh --image-name=busybox --preferred-tag=1.35.0 --image-tags=1.34.1,1.35.0

{
  "busybox" = {

    preferredTag = "1.35.0";

    imageTags = {
      "1.34.1" = {
        sha256 = {
        amd64 = "0kypvap0kblflb8258sr83ninrjnm2xs1c74d5rlbwd4qh3vgzdx";
        arm64 = "1v4s22isa1ac9v4abjvh4aid5i3sz74f74zgvvhrqxnnr79spnwd";
        };
        imageDigest = "sha256:ad9bd57a3a57cc95515c537b89aaa69d83a6df54c4050fcf2b41ad367bec0cd5";
      };
      "1.35.0" = {
        sha256 = {
        amd64 = "10xc4a3fjbc48p9h7jjxfbhivyi6mfv9mkgndbb7kwldg5nj76x6";
        arm64 = "0q2mmnrzcxridija5b2pavgjg5zlzsbaya3bhnf6ad49ksmh995a";
        };
        imageDigest = "sha256:80548a8d85fa32ce25b126657e29e6caf92ce8aa6b4a0bb5708c58a8d6a751f3";
      };
    };
  };
}
