#!/usr/bin/env bash

set -ex

if [ -z "$VAMP_GIT_ROOT" ]; then
  export VAMP_GIT_ROOT=$(git remote -v | grep fetch | awk '{ print $2 }' | awk -F '/' '{ print "git@" $3 ":" $4 }')
fi

if [ -n "$CHANGE_TARGET" ]; then
  export VAMP_CHANGE_TARGET=$CHANGE_TARGET
  export VAMP_CHANGE_URL=$CHANGE_URL
  export VAMP_TAG_PREFIX="pr-$(echo $CHANGE_URL | sed -e 's,.*/vamp-docker-images/pull/,,g')-"
elif [ -n "$BUILD_NUMBER" ]
  export VAMP_TAG_PREFIX="build-$BUILD_NUMBER-"
fi

if [ -n "$VAMP_CHANGE_TARGET" ]; then
  export VAMP_GIT_BRANCH=$VAMP_CHANGE_TARGET
fi

if [ -z "$VAMP_GIT_BRANCH" ]; then
  export VAMP_GIT_BRANCH=$BRANCH_NAME
fi

if [ $VAMP_GIT_BRANCH = "master" ]; then
  unset VAMP_TAG_PREFIX
fi

tag=$(echo $VAMP_GIT_BRANCH | sed 's,/,_,g')
if [ "$VAMP_GIT_BRANCH" = "master" ]; then
  tag=katana
fi
tag="${VAMP_TAG_PREFIX}${tag}"

cd tests/docker

for image in $(docker image ls --format='{{.Repository}}:{{.Tag}}' | grep -ve 'vamp' -ve 'magneticio/java'); do
  docker pull ${image} || true
done

export PACKER="packer-${VAMP_TAG_PREFIX}$(git describe --all | sed 's,/,_,g')"
mkdir -p ${WORKSPACE}/.cache/bower ${WORKSPACE}/.ivy2 ${WORKSPACE}/.node-gyp ${WORKSPACE}/.npm ${WORKSPACE}/.sbt/boot ${WORKSPACE}/.m2/repository
rm -rf ${WORKSPACE}/.ivy2/local
env HOME=$WORKSPACE ./build.sh

if [ -z "$VAMP_CHANGE_TARGET" ]; then
  ./push.sh $tag
fi
