#!/usr/bin/env bash

set -eux -o pipefail

function get-root-dir() {
  local dir="$(dirname ${BASH_SOURCE[0]})"
  (cd "${dir}" && pwd)
}

root="$(get-root-dir)"
source "${root}"/common.sh

images=$(docker image ls --format='{{.Repository}}:{{.Tag}}' | grep -ve 'vamp' -ve 'magneticio/java' -ve ':<none>')
for image in ${images}; do
  docker pull ${image} || true
done

if [ -n "${WORKSPACE:=}" ]; then
  export HOME=${WORKSPACE}
fi

mkdir -p ${HOME}/.cache/bower ${HOME}/.ivy2 ${HOME}/.node-gyp ${HOME}/.npm ${HOME}/.sbt/boot ${HOME}/.m2/repository
rm -rf ${HOME}/.ivy2/local

(cd "${root}/docker" && ./build.sh)
