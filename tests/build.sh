#!/usr/bin/env bash

set -eu -o pipefail

function get-root-dir() {
  local dir=$(dirname "${BASH_SOURCE[0]}")
  (cd "${dir}" && pwd)
}

root="$(get-root-dir)"
source "${root}"/common.sh
test -f "${root}"/../local.sh && source "${root}"/../local.sh

function pull() {
  local image
  for image in ${@}; do
    docker pull ${image}&
  done

  local i
  for i in $(seq ${#}); do
    wait %${i}
  done
}

function pull-deps() {
  pull alpine:3.6 ubuntu:16.04
}

function pull-test-deps() {
  pull java:8-jre-alpine phusion/baseimage
}

function setup-cache-dirs() {
  mkdir -p "${HOME}"/.cache/bower "${HOME}"/.ivy2 "${HOME}"/.node-gyp "${HOME}"/.npm "${HOME}"/.sbt/boot "${HOME}"/.m2/repository
  rm -rf "${HOME}"/.ivy2/local
}

function init-ee() {
  MAKE_TARGET=none "${root}"/../make.sh vamp-docker-images-ee
}

function build-agents() {
  MAKE_TARGET=all "${root}"/../make.sh vamp-gateway-agent vamp-workflow-agent
}

function pack() {
  source "${root}"/build-conf.sh
  MAKE_TARGET=pack "${root}"/../make.sh ${projects}
}

function pack-ui() {
  source "${root}"/build-conf.sh
  MAKE_TARGET=pack "${root}"/../make.sh ${ui_projects}
}

function pack-ee() {
  source "${root}"/../target/vamp-docker-images-ee/tests/build-conf.sh
  MAKE_TARGET=pack "${root}"/../make.sh ${ee_projects}
}

function pack-ee-ui() {
  source "${root}"/../target/vamp-docker-images-ee/tests/build-conf.sh
  MAKE_TARGET=pack "${root}"/../make.sh ${ee_ui_projects}
}

function build() {
  local image
  for image in ${@}; do
    "${root}"/../build.sh --build --version=${VAMP_VERSION} --image=${image}
  done
}

function build-images() {
  "${root}"/../build.sh --make --image=alpine-jdk
  build vamp vamp-custom vamp-dcos vamp-kubernetes
}

function build-clique() {
  build clique-base clique-zookeeper clique-zookeeper-marathon
}

function build-quick-start() {
  "${root}"/../build.sh --build --version=${VAMP_VERSION} --image=quick-start
  docker tag "magneticio/vamp-quick-start:${VAMP_VERSION}" "magneticio/vamp-docker:${VAMP_VERSION}"
}

function build-ee-images() {
  source "${root}"/../target/vamp-docker-images-ee/tests/build-conf.sh
  for image in ${ee_images}; do
    "${root}"/../target/vamp-docker-images-ee/$image/build.sh ${VAMP_VERSION}
  done
}

function build-test-images() {
  MAKE_TARGET=all "${root}"/../make.sh vamp-runner
  MAKE_TARGET=image "${root}"/../make.sh vamp-ui-rspec
}

if [ -z "${@}" ]; then
  ${MAKE:-make} -C "${root}" ${MAKE_OPTS:--j --output-sync} ${MAKE_TARGET:-all} -f - <<'EOF'
.PHONY: all init-ee pull-deps pull-test-deps setup-cache-dirs
.PHONY: pack pack-ui pack-ee pack-ee-ui
.PHONY: build-agents build-images build-clique build-quick-start build-ee-images build-test-images
.SUFFIXES:

all               : build-agents build-images build-quick-start build-ee-images ;
init-ee           :                                                             ; ./build.sh $(@)
pull-deps         :                                                             ; ./build.sh $(@)
pull-test-deps    :                                                             ; ./build.sh $(@)
setup-cache-dirs  :                                                             ; ./build.sh $(@)
pack              : setup-cache-dirs                                            ; ./build.sh $(@)
pack-ui           : setup-cache-dirs                                            ; ./build.sh $(@)
pack-ee           : pack init-ee                                                ; ./build.sh $(@)
pack-ee-ui        : setup-cache-dirs init-ee                                    ; ./build.sh $(@)
build-agents      : pull-deps setup-cache-dirs                                  ; ./build.sh $(@)
build-images      : pull-deps pack pack-ui                                      ; ./build.sh $(@)
build-clique      : pull-deps                                                   ; ./build.sh $(@)
build-quick-start : build-clique pack pack-ui                                   ; ./build.sh $(@)
build-ee-images   : build-images pack-ee pack-ee-ui                             ; ./build.sh $(@)
build-test-images : pull-test-deps setup-cache-dirs                             ; ./build.sh $(@)

EOF
else
  for cmd in ${@}; do
    ${cmd}
  done
fi
