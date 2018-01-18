#!/usr/bin/env bash

set -x

source tests/common.sh

exited_containers=$(docker ps -a -f status=exited -q)
dead_containers=$(docker ps -a -f status=dead -q)
test -n "${exited_containers}" -o -n "${dead_containers}" && docker rm ${exited_containers} ${dead_containers}

if [ "$VAMP_GIT_BRANCH" != "master" ]; then
  remote_images=$(docker image ls -f reference="magneticio/vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
  local_images=$(docker image ls -f reference="vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
  test -n "${remote_images}" -o -n "${local_images}" && docker rmi -f ${remote_images} ${local_images}
fi

dangling_images=$(docker image ls -f dangling=true -q)
while [ -n "${dangling_images}" ]; do
  docker rmi -f ${dangling_images}
  dangling_images=$(docker image ls -f dangling=true -q)
done

docker volume rm "${PACKER}" 2>/dev/null
dangling_volumes=$(docker volume ls -f dangling=true -q | grep -vEe '^packer')
test -n "${dangling_volumes}" && docker volume rm ${dangling_volumes}

find ${WORKSPACE}/target -type d -name 'scala-2.*' | xargs -I {} find {} -maxdepth 1 -type f -name '*.jar' -print -delete

exit 0
