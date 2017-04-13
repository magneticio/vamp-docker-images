#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

if [[ -z $1 ]] ; then
  >&2 echo "Missing argument!"
  echo "Usage:"
  echo "  release-build.sh <version>"
  echo ""
  echo "Example:"
  echo "  release-build.sh 0.9.3"
  exit 1
else
  TAG="$1"
  if [[ $( git describe --tags ) != "$TAG" ]] ; then
    >&2 echo "${red}Error: Provided tag doesn't match repository tag!${reset}"
    >&2 echo "Have you exectued 'release-tag.sh'???"
    >&2 echo "Exiting..."
    exit 1
  fi
fi

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗     ██████╗ ██╗   ██╗███████╗██╗  ██╗███████╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗    ██╔══██╗██║   ██║██╔════╝██║  ██║██╔════╝██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝    ██████╔╝██║   ██║███████╗███████║█████╗  ██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝     ██╔═══╝ ██║   ██║╚════██║██╔══██║██╔══╝  ██╔══██╗
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║         ██║     ╚██████╔╝███████║██║  ██║███████╗██║  ██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝         ╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                                                     by magnetic.io
${reset}"

docker_images="
  magneticio/vamp:${TAG}
  magneticio/vamp:${TAG}-custom
  magneticio/vamp:${TAG}-dcos
  magneticio/vamp:${TAG}-kubernetes
  magneticio/vamp-runner:${TAG}
  magneticio/vamp-gateway-agent:${TAG}
  magneticio/vamp-workflow-agent:${TAG}
  magneticio/vamp-docker:${TAG}
"

# Check that we have our images available
for image in $docker_images ; do
  if [[ $( docker images --format "{{.Repository}}:{{.Tag}}" "$image" ) = "$image" ]] ; then
    echo "${green}Found matching image: ${image}${reset}"
  else
    >&2 echo "${red}Error: No such image: ${image}${reset}"
    >&2 echo "Have you exectued 'release-build.sh'???"
    >&2 echo "Exiting..."
    exit 1
  fi
done

for image in $docker_images ; do
  echo "${green}Pushing image: ${image}${reset}"
  docker push "$image"
done

# echo "${green}Pushing git tags${reset}"
# ${root}/release-tag.sh "$TAG" push
# git push --tags
