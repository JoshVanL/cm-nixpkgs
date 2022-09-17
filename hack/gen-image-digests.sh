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

# This script is used to generate the image digests.

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.."
cd "$ROOT_DIR"

# Add user nix config so that flakes are enabled for the script.
export NIX_USER_CONF_FILES=${ROOT_DIR}/hack/nix/nix.conf

# If this environment variable is not set, then that means that we are not in a
# nix shell, and the command was not invoked with `nix develop -c
# ./hack/gen-image-digests.sh` or similar.
if ! [ -v IN_NIX_SHELL ]; then
  exec nix develop -c ${ROOT_DIR}/hack/gen-image-digests.sh $@
fi

declare {REPO,IMAGE_PREFIX,VERSION_PREFIX,IMAGE_NAME,IMAGE_TAGS}=''
OPTS=$(getopt -o '' -a --longoptions 'repo:,image-prefix:,version-prefix:,image-name:,image-tags:' -n "$0" -- "$@")
if [[ $? -ne 0 ]] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    --repo ) REPO="$2" ; shift 2 ;;
    --image-prefix ) IMAGE_PREFIX="$2" ; shift 2 ;;
    --version-prefix ) VERSION_PREFIX="$2" ; shift 2 ;;
    --image-name ) IMAGE_NAME="$2" ; shift 2 ;;
    --image-tags ) IMAGE_TAGS="$2" ; shift 2 ;;
    -- ) shift ; break ;;
    *)
        echo ""
        echo "Error in given Parameters. Undefined: "
        echo $*
        echo ""
        echo "Usage: $0 [--repo REPO] [--image-prefix IMAGE_PREFIX] [--version-prefix VERSION_PREFIX] [--image-name IMAGE_NAME] [--image-tags IMAGE_TAGS]"
        exit 1
  esac
done

for ARG in REPO IMAGE_PREFIX VERSION_PREFIX IMAGE_NAME IMAGE_TAGS; do
  if [ -z "${!ARG}" ]; then
    echo "Missing required argument: $ARG"
    exit 1
  fi
done

  #echo "  repo = \"${REPO}\";"
  #echo "  imagePrefix = \"${IMAGE_PREFIX}\";"
  #echo "  versionPrefix = \"${VERSION_PREFIX}\";"

cat << EOF
This is probably going to take a while... Hold tight."
---
EOF

cat << EOF
{ lib }:

with lib;

let
  repo = "quay.io/jetstack";
  imagePrefix = "cert-manager-";

  images-src = {
    ${IMAGE_NAME} = {
EOF



for IMAGE_TAG in ${IMAGE_TAGS//,/ }; do
    cat << EOF
      "${IMAGE_TAG}" = {
EOF
  for ARCH in "amd64" "arm64"; do
    IMAGE=$(nix-prefetch-docker --quiet \
      --image-name ${REPO}/${IMAGE_PREFIX}${IMAGE_NAME} \
      --image-tag ${IMAGE_TAG} \
      --os linux \
      --arch ${ARCH} \
      --json)

    echo $IMAGE
  done
done

echo "---"
echo "Done!"
