#!/usr/bin/env bash

# Helper functions
export TERM=xterm # XXX: To get around 'tput: No value for $TERM and no -T specified'
info() { echo "$(date +%T): $(tput setaf 2)INFO:$(tput sgr0) $@"; }
warn() { echo "$(date +%T): $(tput setaf 3)WARN:$(tput sgr0) $@"; }
erro() { echo "$(date +%T): $(tput setaf 1)ERRO:$(tput sgr0) $@" >&2; }
errexit() { erro "$@"; erro "Exiting!"; exit 1; }

set -o errexit # Abort script at first error (command exits non-zero).

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

if [[ -z $1 ]] ; then
  >&2 echo "Missing argument!"
  echo "Usage:"
  echo "  test-push.sh <BRANCH_NAME>"
  echo ""
  echo "Example:"
  echo "  test-push.sh dev"
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
  magneticio/vamp-ee
  magneticio/vamp-ee-lifter
  magneticio/vamp-gateway-agent
  magneticio/vamp-workflow-agent
  magneticio/vamp-docker
  magneticio/vamp-runner
"

# Check that we have our images available
for i in $docker_images; do
  declare -i is_custom=$(docker images --format "{{.Repository}}:{{.Tag}}" "$i:*" | grep -Ei ':[a-z].+' | wc -l)
  if [ $is_custom -gt 0 ]; then
    for j in $(docker images --format "{{.Repository}}:{{.Tag}}" "$i:*" | grep -E ":$TAG"); do
      if [ "$TAG" = "master" ]; then
        image="${j/master/katana}"
        echo "${green}Pushing image: ${image}${reset}"
        docker tag "$j" "$image"
        docker push "$image"
      else
        echo "${green}Pushing image: ${j}${reset}"
        docker push "$j"
      fi
    done
  else
    if [ "$TAG" = "master" ]; then
      declare -i is_release=$(docker images --format "{{.Repository}}:{{.Tag}}" "$i:*" | grep -E ':[0-9]\.' | wc -l)
      if [ $is_release -gt 0 ]; then
        for j in $(docker images --format "{{.Repository}}:{{.Tag}}" "$i:*" | grep -E ':[0-9]\.'); do
          image="${j/[0-9]\.[0-9]\.[0-9]/katana}"
          echo "${green}Pushing image: ${image}${reset}"
          docker tag "$j" "$image"
          docker push "$image"
        done
      else
        >&2 echo "${red}Error: No such image: ${i}${reset}"
        >&2 echo "Exiting..."
        exit 1
      fi
    fi
  fi
done

sed -i -e "s/\(\"image\": \"magneticio\/vamp:\).*\(-dcos\",\)/\1$TAG\2/g" ../dcos/marathon/vamp.json
