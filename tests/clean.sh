#!/usr/bin/env bash

set -ux -o pipefail

function get-root-dir() {
  local dir="$(dirname ${BASH_SOURCE[0]})"
  (cd "${dir}" && pwd)
}

root="$(get-root-dir)"
source "${root}"/common.sh

function filter-images-in-use() {
  local used=$(docker ps --format '{{.Image}}' | grep -v ':')
  local image
  while read image; do
    test -n "${used/*${image}*/}" && echo ${image}
  done
}

exited_containers=$(docker ps -a -f status=exited -q)
dead_containers=$(docker ps -a -f status=dead -q)
test -n "${exited_containers}" -o -n "${dead_containers}" && docker rm ${exited_containers} ${dead_containers}

if [ "${tag}" != "katana" ]; then
  remote_images=$(docker image ls -f reference="magneticio/vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
  local_images=$(docker image ls -f reference="vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
  test -n "${remote_images}" -o -n "${local_images}" && docker rmi -f ${remote_images} ${local_images}
fi

dangling_images=$(docker image ls -qf dangling=true | filter-images-in-use)
while [ -n "${dangling_images}" ]; do
  docker rmi -f ${dangling_images}
  dangling_images=$(docker image ls -qf dangling=true | filter-images-in-use)
done

docker volume rm "${PACKER}" 2>/dev/null
dangling_volumes=$(docker volume ls -f dangling=true -q | grep -vEe '^packer')
test -n "${dangling_volumes}" && docker volume rm ${dangling_volumes}

test -d "${root}/../target" && find "${_}" -type d -name 'scala-2.*' | xargs -I {} find {} -maxdepth 1 -type f -name '*.jar' -print -delete

exit 0
