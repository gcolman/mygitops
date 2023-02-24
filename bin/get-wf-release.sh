#!/usr/bin/env bash

# To use this, *source* into a script in which BIN has been set to the folder you want WF to be
# placed in. https://storage.googleapis.com/wayfinder-dev-releases/v1.7.0-dev1/wf-cli-linux-amd64

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. >/dev/null 2>&1 && pwd)"

WF_VERSION="${WF_VERSION:-"${VERSION:-"latest"}"}"
RELEASE_BUCKET=wayfinder-releases
LOCAL_WF=${LOCAL_WF:-"false"}
BIN=${BIN:-$(pwd)/wfbin}


JSON_FILE=$1
echo -n "JSON_FILE ${JSON_FILE} \n"

RELEASE_BUCKET="$(cat ${JSON_FILE} | jq -r '.cli.bucket')"
WF_VERSION="$(cat ${JSON_FILE} | jq -r '.cli.version')"


if [[ "${LOCAL_WF}" != "true" ]]; then
  mkdir -p "${BIN}" || true
  export PATH=${BIN}:${PATH}
  echo "Downloading WF version ${WF_VERSION} from ${RELEASE_BUCKET} to ${BIN}/wf"
  binname=wf-cli-linux-amd64
  if [ "$(uname)" == "Darwin" ]; then
    binname=wf-cli-darwin-amd64
  fi
  curl --fail -sSL https://storage.googleapis.com/${RELEASE_BUCKET}/${WF_VERSION}/${binname}.tar.gz --output ${BIN}/wf.tar.gz
  tar -xzf ${BIN}/wf.tar.gz -C ${BIN}
  rm ${BIN}/wf.tar.gz
  mv ${BIN}/${binname} ${BIN}/wf
fi

echo "Using WF CLI: $(wf version)"