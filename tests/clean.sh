#!/usr/bin/env bash

set -x

if [ -n "$VAMP_CHANGE_TARGET" ]; then
  export VAMP_GIT_BRANCH=$VAMP_CHANGE_TARGET
fi

if [ -n "$CHANGE_TARGET" ]; then
  export VAMP_GIT_BRANCH=$CHANGE_TARGET
  export VAMP_TAG_PREFIX="pr-$(echo $CHANGE_URL | sed -e 's,.*/vamp-docker-images/pull/,,g')-"
else
  export VAMP_TAG_PREFIX="build-$BUILD_NUMBER-"
fi

if [ -z "$VAMP_GIT_BRANCH" ]; then
  export VAMP_GIT_BRANCH=$BRANCH_NAME
fi

if [ $VAMP_GIT_BRANCH = "master" ]; then
  unset VAMP_TAG_PREFIX
fi

tag=$(echo $VAMP_GIT_BRANCH | sed 's,/,_,g')
if [ "$VAMP_GIT_BRANCH" = "master" ]; then
  tag="katana--"
fi
tag="${VAMP_TAG_PREFIX}${tag}"

exited_containers=$(docker ps -a -f status=exited -q)
dead_containers=$(docker ps -a -f status=dead -q)
test -n "${exited_containers}" -o -n "${dead_containers}" && docker rm ${exited_containers} ${dead_containers}

remote_images=$(docker image ls -f reference="magneticio/vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
local_images=$(docker image ls -f reference="vamp*:${tag}*" --format '{{.Repository}}:{{.Tag}}')
test -n "${remote_images}" -o -n "${local_images}" && docker rmi -f ${remote_images} ${local_images}

dangling_images=$(docker image ls -f dangling=true -q)
while [ -n "${dangling_images}" ]; do
  docker rmi -f ${dangling_images}
  dangling_images=$(docker image ls -f dangling=true -q)
done

docker volume rm "packer-${VAMP_TAG_PREFIX}$(git describe --all | sed 's,/,_,g')" 2>/dev/null
dangling_volumes=$(docker volume ls -f dangling=true -q | grep -vEe '^packer')
test -n "${dangling_volumes}" && docker volume rm ${dangling_volumes}

find ${WORKSPACE}/target -type d -name 'scala-2.*' | xargs -I {} find {} -maxdepth 1 -type f -name '*.jar' -print -delete

exit 0
