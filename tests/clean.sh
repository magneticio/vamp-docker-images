#!/usr/bin/env bash

set -ux -o pipefail

function get-root-dir() {
  local dir=$(dirname "${BASH_SOURCE[0]}")
  (cd "${dir}" && pwd)
}

root="$(get-root-dir)"
test -f "${root}"/../local.sh && source "${root}"/../local.sh
source "${root}"/common.sh

docker container prune --force --filter "until=${PRUNE_DURATION}"

if [ "${VAMP_VERSION}" != "katana" ]; then
  remote_images=$(docker image ls -f reference="magneticio/vamp*:${VAMP_VERSION/build-${BUILD_NUMBER:=}-/build-*-}*" --format '{{.Repository}}:{{.Tag}}')
  local_images=$(docker image ls -f reference="vamp*:${VAMP_VERSION}*" --format '{{.Repository}}:{{.Tag}}')
  test -n "${remote_images}" -o -n "${local_images}" && docker rmi -f ${remote_images} ${local_images}
fi

docker image prune --force --filter "until=${PRUNE_DURATION}"

volumes=$(docker volume ls -qf name="${PACKER/build-${BUILD_NUMBER:=}-/build-*-}")
test ${KEEP_PACKER:-false} = "true" || docker volume rm "${volumes}"

dangling_volumes=$(docker volume ls -f dangling=true -q | grep -vEe '^packer')
test -n "${dangling_volumes}" && docker volume rm ${dangling_volumes}

test -d "${root}"/../target && find "${_}" -type d -name 'scala-2.*' | xargs -I {} find {} -maxdepth 1 -type f -name '*.jar' -print -delete

exit 0
