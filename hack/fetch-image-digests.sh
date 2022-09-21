#!/usr/bin/env bash

# Copyright 2022 The cert-manager Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

# This script is used to fetch image digests of a given image. The output is a
# nix file which should be copied in part of in whole to the relevant file in
# `pkgs/images`.
#
# Usage:
# $ ./hack/fetch-image-digests.sh --image-name=quay.io/jetstack/cert-manager-controller --preferred-tag=v1.9.1 --image-tags=v1.9.0,v1.9.1

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.."
cd "$ROOT_DIR"

COMMAND="nix develop -c ./hack/fetch-image-digests.sh $@"

# Add user nix config so that flakes are enabled for the script.
export NIX_USER_CONF_FILES=${ROOT_DIR}/hack/nix/nix.conf

# If this environment variable is not set, then that means that we are not in a
# nix shell, and the command was not invoked with `nix develop -c
# ./hack/fetch-image-digests.sh` or similar.
if ! [ -v IN_NIX_SHELL ]; then
  exec ${COMMAND}
fi

declare {IMAGE_NAME,IMAGE_TAGS,PREFERRED_TAG}=''
OPTS=$(getopt -o '' -a --longoptions 'image-name:,image-tags:,preferred-tag:' -n "$0" -- "$@")
if [[ $? -ne 0 ]] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    --image-name ) IMAGE_NAME="$2" ; shift 2 ;;
    --image-tags ) IMAGE_TAGS="$2" ; shift 2 ;;
    --preferred-tag ) PREFERRED_TAG="$2" ; shift 2 ;;
    -- ) shift ; break ;;
    *)
        echo ""
        echo "Error in given Parameters. Undefined: "
        echo $*
        echo ""
        echo "Usage: $0 [--image-name IMAGE_NAME] [--image-tags IMAGE_TAGS] [--preferred-tag PREFERRED_TAG]"
        echo "$ ./hack/fetch-image-digests.sh --image-name=quay.io/jetstack/cert-manager-controller --preferred-tag=v1.9.1 --image-tags=v1.9.0,v1.9.1"
        exit 1
  esac
done

for ARG in IMAGE_NAME IMAGE_TAGS PREFERRED_TAG; do
  if [ -z "${!ARG}" ]; then
    echo "Missing required argument: $ARG"
    echo "[--image-name IMAGE_NAME] [--image-tags IMAGE_TAGS] [--preferred-tag PREFERRED_TAG]"
    echo "$ ./hack/fetch-image-digests.sh --image-name=quay.io/jetstack/cert-manager-controller --preferred-tag=v1.9.1 --image-tags=v1.9.0,v1.9.1"
    exit 1
  fi
done

cat << EOF
The following output should be copied in whole or in part into the relevant
image file in the 'pkgs/images' directory. This is probably going to take a
while... Hold tight.
---
EOF

cat << EOF
{ }:

# File was generated with:
# $ ${COMMAND}

{
  "${IMAGE_NAME}" = {

    preferredTag = "${PREFERRED_TAG}";

    imageTags = {
EOF

for IMAGE_TAG in ${IMAGE_TAGS//,/ }; do
    cat << EOF
      "${IMAGE_TAG}" = {
        sha256 = {
EOF
  IMAGE=""
  for ARCH in "amd64" "arm64"; do
    IMAGE=$(nix-prefetch-docker --quiet \
      --image-name ${IMAGE_NAME} \
      --image-tag ${IMAGE_TAG} \
      --os linux \
      --arch ${ARCH} \
      --json)

    echo "          ${ARCH} = $(echo ${IMAGE} | jq .sha256);"

  done
  cat << EOF
        };
        imageDigest = $(echo ${IMAGE} | jq .imageDigest);
      };
EOF
done

cat << EOF
    };
  };
}
EOF

echo "---"
echo "Done!"
