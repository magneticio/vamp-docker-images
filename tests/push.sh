#!/usr/bin/env bash

set -eu -o pipefail

function get-root-dir() {
  local dir=$(dirname "${BASH_SOURCE[0]}")
  (cd "${dir}" && pwd)
}

root="$(get-root-dir)"

test -z "${@}" && source "${root}"/common.sh
test -z "${VAMP_CHANGE_TARGET:=}" || exit

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗     ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗    ██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝    ██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝     ██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║         ██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝         ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝
                                                                     by magnetic.io
${reset}"

source "${root}"/push-conf.sh
source "${root}"/../target/vamp-docker-images-ee/tests/push-conf.sh

function push() {
  local repo=${1}
  shift

  local tag image
  for tag in ${@}; do
    for image in $(docker images --format "{{.Repository}}:{{.Tag}}" "${repo}:${tag}*"); do
      echo "${green}Pushing image: ${image}${reset}"
      docker push "${image}"
    done
  done
}

for i in ${docker_images} ${ee_images}; do
  HOME=${PUSH_HOME:-${HOME}} push "${i}" ${@:-${VAMP_VERSION}}
done
