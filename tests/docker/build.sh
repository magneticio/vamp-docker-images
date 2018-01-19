#!/usr/bin/env bash

set -eu -o pipefail

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

test -f ${root}/../../local.sh && source ${root}/../../local.sh
source ${root}/../build-conf.sh
source ${root}/../../target/vamp-docker-images-ee/tests/build-conf.sh

# that is, whassup! ... true
MAKE=true ${root}/../../pack.sh vamp-docker-images-ee

BUILD_TARGET=all ${root}/../../pack.sh vamp-gateway-agent vamp-workflow-agent

${root}/../../build.sh --make --image=alpine-jdk
${root}/../../pack.sh ${projects} ${ee_projects}

${root}/../../build.sh --build --version=${VAMP_VERSION} --image=vamp
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=vamp-custom
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=vamp-dcos
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=vamp-kubernetes

${root}/../../build.sh --build --version=${VAMP_VERSION} --image=clique-base
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=clique-zookeeper
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=clique-zookeeper-marathon
${root}/../../build.sh --build --version=${VAMP_VERSION} --image=quick-start
docker tag "magneticio/vamp-quick-start:${VAMP_VERSION}" "magneticio/vamp-docker:${VAMP_VERSION}"

for image in $ee_images; do
  ${root}/../../target/vamp-docker-images-ee/$image/build.sh ${VAMP_VERSION}
done
