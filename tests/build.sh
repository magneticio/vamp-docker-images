#!/usr/bin/env bash

set -ex

source tests/common.sh

cd tests/docker

for image in $(docker image ls --format='{{.Repository}}:{{.Tag}}' | grep -ve 'vamp' -ve 'magneticio/java'); do
  docker pull ${image} || true
done

if [ -n "$WORKSPACE" ]; then
  export HOME=$WORKSPACE
fi

mkdir -p ${HOME}/.cache/bower ${HOME}/.ivy2 ${HOME}/.node-gyp ${HOME}/.npm ${HOME}/.sbt/boot ${HOME}/.m2/repository
rm -rf ${HOME}/.ivy2/local

./build.sh

if [ -z "$VAMP_CHANGE_TARGET" ]; then
  ../push.sh $tag
fi
