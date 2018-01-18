#!/usr/bin/env bash

# Helper functions
export TERM=xterm # XXX: To get around 'tput: No value for $TERM and no -T specified'
info() { echo "$(date +%T): $(tput setaf 2)INFO:$(tput sgr0) $@"; }
warn() { echo "$(date +%T): $(tput setaf 3)WARN:$(tput sgr0) $@"; }
erro() { echo "$(date +%T): $(tput setaf 1)ERRO:$(tput sgr0) $@" >&2; }
errexit() { erro "$@"; erro "Exiting!"; exit 1; }

set -o errexit # Abort script at first error (command exits non-zero).

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
workspace="../../target"

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

if [[ -z $1 ]] ; then
  >&2 echo "Missing argument!"
  echo "Usage:"
  echo "  test-push.sh <TAG_NAME>"
  echo ""
  echo "Example:"
  echo "  test-push.sh katana"
  exit 1
else
  TAG="$1"
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

docker_images="
  magneticio/vamp
  magneticio/vamp-gateway-agent
  magneticio/vamp-workflow-agent
  magneticio/vamp-docker
"
source ${workspace}/vamp-docker-images-ee/tests/push-conf.sh

# Check that we have our images available
for i in $docker_images $ee_images; do
  for j in $(docker images --format "{{.Repository}}:{{.Tag}}" "$i:$TAG*"); do
    echo "${green}Pushing image: ${j}${reset}"
    docker push "$j"
  done
done
