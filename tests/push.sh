#!/usr/bin/env bash

# Helper functions
TERM=${TERM:-xterm}
test -z "${TERM/*xterm*/}" || TERM=xterm
export TERM

set -eu -o pipefail

function get-root-dir() {
  local dir="$(dirname ${BASH_SOURCE[0]})"
  (cd "${dir}" && pwd)
}

root="$(get-root-dir)"

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

if [ ${#} -eq 0 ]; then
  >&2 echo "Missing argument!"
  echo "Usage:"
  echo "  ${BASH_SOURCE[0]} <TAG_NAME> ..."
  echo ""
  echo "Examples:"
  echo "  ${BASH_SOURCE[0]} katana"
  echo "  ${BASH_SOURCE[0]} katana build-101-katana"
  exit 1
fi

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗     ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗    ██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝    ██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝     ██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║         ██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝         ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝
                                                                     by magnetic.io
${reset}"

source ${root}/push-conf.sh
source ${root}/../target/vamp-docker-images-ee/tests/push-conf.sh

for tag in ${@}; do
  for i in $docker_images $ee_images; do
    for j in $(docker images --format "{{.Repository}}:{{.Tag}}" "${i}:${tag}*"); do
      echo "${green}Pushing image: ${j}${reset}"
      docker push "$j"
    done
  done
done
