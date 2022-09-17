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

# This script is used to fetch helm Chart digests of a given helm Chart. The
# output is a nix file which should be copied in part of in whole to the
# relevant file in `pkgs/charts`.
#
# Usage:
# $ ./hack/fetch-chart-digests.sh --chart-url=https://charts.jetstack.io/charts --chart-name cert-manager --preferred-version=v1.9.1 --chart-versions=v1.9.0,v1.9.1

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.."
cd "$ROOT_DIR"

COMMAND="nix develop -c ./hack/fetch-chart-digests.sh $@"

# Add user nix config so that flakes are enabled for the script.
export NIX_USER_CONF_FILES=${ROOT_DIR}/hack/nix/nix.conf

# If this environment variable is not set, then that means that we are not in a
# nix shell, and the command was not invoked with `nix develop -c
# ./hack/fetch-chart-digests.sh` or similar.
if ! [ -v IN_NIX_SHELL ]; then
  exec ${COMMAND}
fi

echo $@

declare {CHART_URL,CHART_NAME,CHART_VERSIONS,PREFERRED_VERSION}=''
OPTS=$(getopt -o '' -a --longoptions 'chart-url:,chart-name:,preferred-version:,chart-versions:' -n "$0" -- "$@")
if [[ $? -ne 0 ]] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case "$1" in
    --chart-url ) CHART_URL="$2" ; shift 2 ;;
    --chart-name ) CHART_NAME="$2" ; shift 2 ;;
    --preferred-version ) PREFERRED_VERSION="$2" ; shift 2 ;;
    --chart-versions ) CHART_VERSIONS="$2" ; shift 2 ;;
    -- ) shift ; break ;;
    *)
        echo ""
        echo "Error in given Parameters. Undefined: "
        echo $*
        echo ""
        echo "Usage: $0 [--chart-url CHART_URL] [--chart-name CHART_NAME] [--preferred-version PREFERRED_VERSION] [--chart-versions CHART_VERSIONS]"
        echo "$ ./hack/fetch-chart-digests.sh --chart-url=https://charts.jetstack.io/charts --chart-name cert-manager --preferred-version=v1.9.1 --chart-versions=v1.9.0,v1.9.1"
        exit 1
  esac
done

for ARG in CHART_URL CHART_NAME PREFERRED_VERSION CHART_VERSIONS; do
  if [ -z "${!ARG}" ]; then
    echo "Missing required argument: $ARG"
    echo "[--chart-url CHART_URL] [--chart-name CHART_NAME] [--preferred-version PREFERRED_VERSION] [--chart-versions CHART_VERSIONS]"
    echo "$ ./hack/fetch-chart-digests.sh --chart-url=https://charts.jetstack.io/charts --chart-name cert-manager --preferred-version=v1.9.1 --chart-versions=v1.9.0,v1.9.1"
    exit 1
  fi
done

cat << EOF
The following output should be copied in whole or in part into the relevant
chart file in the 'pkgs/charts' directory. This is probably going to take a
while... Hold tight.
---
EOF

cat << EOF
{ }:

# File was generated with:
# $ ${COMMAND}

{
  "${CHART_URL}/${CHART_NAME}" = {

    preferredVersion = "${PREFERRED_VERSION}";

    versions = {
EOF

for VERSION in ${CHART_VERSIONS//,/ }; do
  SHA256=$(nix-prefetch-url --unpack "${CHART_URL}/${CHART_NAME}-${VERSION}.tgz" 2> /dev/null)
  cat << EOF
      "${VERSION}" = {
        sha256 = "${SHA256}";
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
